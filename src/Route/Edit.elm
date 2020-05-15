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
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "justify-content" "center"
        , style "height" "100%"
        ]
        [ div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "height" "100%"
            , style "flex-basis" "60%"
            ]
            [ div
                [ style "display" "flex"
                , style "flex-direction" "row"
                , style "justify-content" "flex-end"
                , style "padding" "5px 10px"
                ]
                [ button
                    [ style "appearance" "none"
                    , style "border" "solid"
                    , style "height" "30px"
                    , style "width" "80px"
                    , style "border-radius" "15px"
                    , style "border-width" "2px"
                    , style "background" "none"
                    , style "letter-spacing" "1px"
                    , style "font-family" "sans-serif"
                    , style "font-weight" "bold"
                    , style "outline" "none"
                    , onClick Tweet
                    ]
                    [ text "Tweet" ]
                ]
            , div
                [ style "display" "flex"
                , style "flex-direction" "row"
                , style "flex-grow" "1"
                , style "justify-content" "center"
                , style "padding" "0px 10px"
                ]
                [ label
                    [ style "font-family" "monospace"
                    , for "text"
                    ]
                    [ text ">" ]
                , textarea
                    [ style "appearance" "none"
                    , style "border" "none"
                    , style "resize" "none"
                    , style "outline" "none"
                    , style "flex-grow" "1"
                    , id "text"
                    , onInput Edit
                    ]
                    []
                ]
            ]
        ]
