module Compress exposing (decode, encode)

import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Compress.Format as Format
import Compress.Format.V2 as V2
import Compress.QueryDecoder as QD
import Compress.QueryEncoder as QE
import Flate
import Time exposing (Posix)


encodeWith : (String -> String) -> (a -> BE.Encoder) -> a -> Maybe String
encodeWith queryEncoder encoder data =
    data
        |> encoder
        |> BE.encode
        |> Flate.deflate
        |> Base64.fromBytes
        |> Maybe.map queryEncoder


decodeWith : (String -> String) -> (Int -> BD.Decoder a) -> String -> Maybe a
decodeWith queryDecoder decoder compressed =
    compressed
        |> queryDecoder
        |> Base64.toBytes
        |> Maybe.andThen Flate.inflate
        |> Maybe.andThen (\b -> BD.decode (decoder (Bytes.width b)) b)


encode : Format.Version -> ( Posix, String ) -> Maybe String
encode version =
    encodeWith (QE.fromVersion version) (formatEncoder version)


formatEncoder : Format.Version -> ( Posix, String ) -> BE.Encoder
formatEncoder version data =
    BE.sequence
        [ versionEncoder version
        , selectEncoder version data
        ]


versionEncoder : Format.Version -> BE.Encoder
versionEncoder version =
    Format.versionToInt version |> BE.unsignedInt8


selectEncoder : Format.Version -> ( Posix, String ) -> BE.Encoder
selectEncoder version =
    case version of
        Format.V1 ->
            V2.encoder

        Format.V2 ->
            V2.encoder

        Format.Unknown ->
            V2.encoder


decode : Maybe Format.Version -> String -> Maybe ( Posix, String )
decode versionHint =
    decodeWith (QD.fromVersion (Maybe.withDefault Format.V2 versionHint)) (formatDecoder versionHint)


formatDecoder : Maybe Format.Version -> Int -> BD.Decoder ( Posix, String )
formatDecoder versionHint width =
    case versionHint of
        Just Format.V1 ->
            selectDecoder width Format.V1

        _ ->
            versionDecoder |> BD.andThen (selectDecoder (width - 1))


versionDecoder : BD.Decoder Format.Version
versionDecoder =
    BD.unsignedInt8 |> BD.map Format.intToVersion


selectDecoder : Int -> Format.Version -> BD.Decoder ( Posix, String )
selectDecoder width version =
    case version of
        Format.V1 ->
            V2.decoder width

        Format.V2 ->
            V2.decoder width

        Format.Unknown ->
            V2.decoder width
