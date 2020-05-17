module Compress exposing (decode, encode)

import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Compress.Format as Format
import Compress.Format.V2 as V2
import Flate
import Time exposing (Posix)


encodeWith : (a -> BE.Encoder) -> a -> Maybe String
encodeWith encoder data =
    data
        |> encoder
        |> BE.encode
        |> Flate.deflate
        |> Base64.fromBytes
        |> Maybe.map
            (String.replace "+" "-" >> String.replace "/" "_" >> String.replace "=" "")


decodeWith : (Int -> BD.Decoder a) -> String -> Maybe a
decodeWith decoder compressed =
    compressed
        |> String.replace "-" "+"
        |> String.replace "_" "/"
        |> Base64.toBytes
        |> Maybe.andThen Flate.inflate
        |> Maybe.andThen (\b -> BD.decode (decoder (Bytes.width b)) b)


encode : Format.Version -> ( Posix, String ) -> Maybe String
encode version =
    encodeWith (formatEncoder version)


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
        Format.V2 ->
            V2.encoder

        Format.Unknown ->
            V2.encoder


decode : String -> Maybe ( Posix, String )
decode =
    decodeWith formatDecoder


formatDecoder : Int -> BD.Decoder ( Posix, String )
formatDecoder width =
    versionDecoder |> BD.andThen (selectDecoder width)


versionDecoder : BD.Decoder Format.Version
versionDecoder =
    BD.unsignedInt8 |> BD.map Format.intToVersion


selectDecoder : Int -> Format.Version -> BD.Decoder ( Posix, String )
selectDecoder width version =
    case version of
        Format.V2 ->
            V2.decoder (width - 1)

        Format.Unknown ->
            V2.decoder (width - 1)
