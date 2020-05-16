module Route exposing (Options(..), Route(..), getEditOptions, getShowOptions, route)

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


type Options
    = ShowOptions Route.Show.Options
    | EditOptions Route.Edit.Options


getShowOptions : Options -> Route.Show.Options
getShowOptions options =
    case options of
        ShowOptions opts ->
            opts

        _ ->
            Nothing


getEditOptions : Options -> Route.Edit.Options
getEditOptions options =
    case options of
        EditOptions opts ->
            opts

        _ ->
            Nothing
