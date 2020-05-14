module Compress exposing (decode, encode)

import Base64
import Bytes exposing (Bytes)
import Bytes.Decode as BD
import Bytes.Encode as BE
import Flate


stringToBytes : String -> Bytes
stringToBytes string =
    BE.encode (BE.string string)


bytesToString : Bytes -> Maybe String
bytesToString bytes =
    BD.decode (BD.string (Bytes.width bytes)) bytes


encode : String -> Maybe String
encode string =
    string
        |> stringToBytes
        |> Flate.deflate
        |> Base64.fromBytes
        |> Maybe.map
            (String.replace "+" "-" >> String.replace "/" "-" >> String.replace "=" "_")


decode : String -> Maybe String
decode compressed =
    compressed
        |> String.replace "-" "+"
        |> String.replace "-" "/"
        |> String.replace "_" "="
        |> Base64.toBytes
        |> Maybe.andThen Flate.inflate
        |> Maybe.andThen bytesToString
