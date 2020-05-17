module Route.Edit exposing (Flags, Model, Msg, Options, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import OutMsg exposing (OutMsg)
import Task
import Time exposing (Posix)
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
    | ShareInfoPrepared ShareInfo


type alias Flags =
    ()


type alias Options =
    Maybe String


type alias ShareInfo =
    { text : String
    , date : Posix
    }


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
            ( model, prepareInfo model.text, OutMsg.Noop )

        ShareInfoPrepared info ->
            ( model, loadTwitterSharing model info, OutMsg.Noop )


prepareInfo : String -> Cmd Msg
prepareInfo text =
    Task.perform ShareInfoPrepared (Task.map (ShareInfo text) Time.now)


loadTwitterSharing : Model -> ShareInfo -> Cmd Msg
loadTwitterSharing model info =
    showTextUrl model.url info.text info.date |> Maybe.map (Nav.load << twitterSharingUrl) |> Maybe.withDefault Cmd.none


twitterSharingUrl : String -> String
twitterSharingUrl text =
    UB.crossOrigin "https://twitter.com" [ "intent", "tweet" ] [ UB.string "text" text ]


showTextUrl : Url -> String -> Posix -> Maybe String
showTextUrl url text date =
    Compress.encode ( date, text )
        |> Maybe.map
            ((\t -> [ UB.string "t" t ] |> UB.toQuery |> String.dropLeft 1)
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
