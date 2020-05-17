module Route exposing (Options(..), Route(..), getEditOptions, getShowOptions, route)

import Compress.Format as Format
import Maybe.Extra as Maybe
import Route.Edit
import Route.Show
import Url exposing (Url)
import Url.Parser exposing (..)
import Url.Parser.Query as Query


type Route
    = Show Route.Show.Flags
    | Edit Route.Edit.Flags


text : Url -> Maybe ( String, Maybe Format.Version )
text url =
    parse
        (top <?> Query.map2 selectQuery (Query.string "t") (Query.string "text"))
        { url | path = "" }
        |> Maybe.withDefault Nothing


selectQuery : Maybe String -> Maybe String -> Maybe ( String, Maybe Format.Version )
selectQuery t text_ =
    case t of
        Just txt ->
            Just ( txt, Nothing )

        Nothing ->
            case text_ of
                Just txt ->
                    Just ( txt, Just Format.V1 )

                Nothing ->
                    Nothing


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
