module Compress exposing (decode, encode)

import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Flate
import Time exposing (Posix)


stringEncoder : String -> BE.Encoder
stringEncoder string =
    BE.string string


stringDecoder : Int -> BD.Decoder String
stringDecoder width =
    BD.string width


encodeWith : (a -> BE.Encoder) -> a -> Maybe String
encodeWith encoder data =
    data
        |> encoder
        |> BE.encode
        |> Flate.deflate
        |> Base64.fromBytes
        |> Maybe.map
            (String.replace "+" "-" >> String.replace "/" "." >> String.replace "=" "_")


decodeWith : (Int -> BD.Decoder a) -> String -> Maybe a
decodeWith decoder compressed =
    compressed
        |> String.replace "-" "+"
        |> String.replace "." "/"
        |> String.replace "_" "="
        |> Base64.toBytes
        |> Maybe.andThen Flate.inflate
        |> Maybe.andThen (\b -> BD.decode (decoder (Bytes.width b)) b)


posixEncoder : Posix -> BE.Encoder
posixEncoder date =
    Time.posixToMillis date // 60000 |> BE.unsignedInt32 Bytes.BE


posixDecoder : BD.Decoder Posix
posixDecoder =
    BD.unsignedInt32 Bytes.BE |> BD.map ((*) 60000 >> Time.millisToPosix)


packedEncoder : ( Posix, String ) -> BE.Encoder
packedEncoder ( date, text ) =
    BE.sequence
        [ posixEncoder date
        , stringEncoder text
        ]


packedDecoder : Int -> BD.Decoder ( Posix, String )
packedDecoder width =
    BD.map2 Tuple.pair posixDecoder (stringDecoder (width - 4))


encode : ( Posix, String ) -> Maybe String
encode =
    encodeWith packedEncoder


decode : String -> Maybe ( Posix, String )
decode =
    decodeWith packedDecoder
