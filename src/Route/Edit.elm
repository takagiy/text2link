module Route.Edit exposing (Flags, Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Url exposing (Url)
import Url.Builder as UB


type alias Model =
    { key : Nav.Key
    , text : String
    , url : Url
    }


type Msg
    = Noop
    | Edit String
    | Tweet


type alias Flags =
    ()


init : Url -> Nav.Key -> Flags -> ( Model, Cmd Msg )
init url key _ =
    ( { key = key, text = "", url = url }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        Edit text ->
            ( { model | text = text }, Cmd.none )

        Tweet ->
            ( model, loadTwitterSharing model )


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
view _ =
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
                    []
                , label
                    [ class "label-prompt"
                    , for "text"
                    ]
                    [ text ">" ]
                ]
            ]
        ]
