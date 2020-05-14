module Route exposing (Route(..), route)

import Dict
import Route.Edit
import Route.Show
import Url exposing (Url)
import Url.Parser exposing (..)
import Url.Parser.Query as Query


type Route
    = Show Route.Show.Flags
    | Edit Route.Edit.Flags


text : Url -> Maybe String
text url =
    parse
        (top <?> Query.string "text")
        { url | path = "" }
        |> Maybe.withDefault Nothing


route : Url -> Route
route url =
    text url |> Maybe.map Show |> Maybe.withDefault (Edit ())
