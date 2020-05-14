module Route exposing (Route(..), route)

import Route.Edit
import Route.Show
import Url exposing (Url)
import Url.Parser exposing (..)
import Url.Parser.Query as Query


type Route
    = Show Route.Show.Flags
    | Edit Route.Edit.Flags


router : Parser (Route -> a) a
router =
    oneOf
        [ map Show (s "text2link" <?> Query.string "text")
        , map (Edit ()) (s "text2link" </> s "edit")
        ]


route : Url -> Route
route url =
    parse router url |> Maybe.withDefault (Edit ())
