module Compress exposing (decode, encode, posixDecoder, posixEncoder, stringDecoder, stringEncoder)

import Base64
import Bytes exposing (Bytes)
import Bytes.Decode as BD
import Bytes.Encode as BE
import Flate
import Time exposing (Posix)


stringEncoder : String -> Bytes
stringEncoder string =
    BE.encode (BE.string string)


stringDecoder : Bytes -> Maybe String
stringDecoder bytes =
    BD.decode (BD.string (Bytes.width bytes)) bytes


encode : (a -> Bytes) -> a -> Maybe String
encode toBytes data =
    data
        |> toBytes
        |> Flate.deflate
        |> Base64.fromBytes
        |> Maybe.map
            (String.replace "+" "-" >> String.replace "/" "." >> String.replace "=" "_")


decode : (Bytes -> Maybe a) -> String -> Maybe a
decode fromBytes compressed =
    compressed
        |> String.replace "-" "+"
        |> String.replace "." "/"
        |> String.replace "_" "="
        |> Base64.toBytes
        |> Maybe.andThen Flate.inflate
        |> Maybe.andThen fromBytes


posixEncoder : Posix -> Bytes
posixEncoder date =
    Time.posixToMillis date // 600000 |> BE.unsignedInt32 Bytes.BE |> BE.encode


posixDecoder : Bytes -> Maybe Posix
posixDecoder bytes =
    BD.decode (BD.unsignedInt32 Bytes.BE) bytes |> Maybe.map ((*) 600000 >> Time.millisToPosix)
