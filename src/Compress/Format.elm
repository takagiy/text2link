module Compress.Format exposing (Version(..), intToVersion, versionToInt)


type Version
    = V2
    | Unknown


intToVersion : Int -> Version
intToVersion v =
    case v of
        2 ->
            V2

        _ ->
            Unknown


versionToInt : Version -> Int
versionToInt v =
    case v of
        V2 ->
            2

        Unknown ->
            0
