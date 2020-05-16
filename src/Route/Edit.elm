module Route.Edit exposing (Flags, Model, Msg, Options, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import OutMsg exposing (OutMsg)
import Url exposing (Url)
import Url.Builder as UB


type alias Model =
    { key : Nav.Key
    , text : String
    , defaultText : Maybe String
    , url : Url
    }


type Msg
    = Noop
    | Edit String
    | Tweet


type alias Flags =
    ()


type alias Options =
    Maybe String


init : Url -> Nav.Key -> Flags -> Options -> ( Model, Cmd Msg )
init url key _ options =
    ( { key = key, text = options |> Maybe.withDefault "", url = url, defaultText = options }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none, OutMsg.Noop )

        Edit text ->
            ( { model | text = text }, Cmd.none, OutMsg.Noop )

        Tweet ->
            ( model, loadTwitterSharing model, OutMsg.Noop )


loadTwitterSharing : Model -> Cmd Msg
loadTwitterSharing model =
    showTextUrl model.url model.text |> Maybe.map (Nav.load << twitterSharingUrl) |> Maybe.withDefault Cmd.none


twitterSharingUrl : String -> String
twitterSharingUrl text =
    UB.crossOrigin "https://twitter.com" [ "intent", "tweet" ] [ UB.string "text" text ]


showTextUrl : Url -> String -> Maybe String
showTextUrl url text =
    Compress.encode text
        |> Maybe.map
            ((\t -> [ UB.string "text" t ] |> UB.toQuery |> String.dropLeft 1)
                >> (\q -> { url | query = Just q })
                >> Url.toString
            )


view : Model -> Html Msg
view model =
    div
        [ class "container-screen" ]
        [ div
            [ class "container-main" ]
            [ div
                [ class "container-header" ]
                [ button
                    [ class "button"
                    , onClick Tweet
                    ]
                    [ text "Tweet" ]
                ]
            , div
                [ class "container-text" ]
                [ textarea
                    [ class "text"
                    , id "text"
                    , onInput Edit
                    , placeholder "_"
                    ]
                    [ text (Maybe.withDefault "" model.defaultText)
                    ]
                , label
                    [ class "label-prompt"
                    , for "text"
                    ]
                    [ text ">" ]
                ]
            ]
        ]
