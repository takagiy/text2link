module Compress.QueryDecoder exposing (fromVersion, v1, v2)

import Compress.Format as Format


v1 : String -> String
v1 =
    String.replace "-" "+" >> String.replace "." "/" >> String.replace "_" "="


v2 : String -> String
v2 =
    String.replace "-" "+" >> String.replace "_" "/"


fromVersion : Format.Version -> (String -> String)
fromVersion version =
    case version of
        Format.V1 ->
            v1

        Format.V2 ->
            v2

        Format.Unknown ->
            v2
