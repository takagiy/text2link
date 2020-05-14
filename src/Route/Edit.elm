module Route.Edit exposing (Flags, Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)
import Html.Events exposing (..)
import Url
import Url.Builder as UB


type alias Model =
    { key : Nav.Key
    , text : String
    }


type Msg
    = Noop
    | Edit String
    | Tweet


type alias Flags =
    ()


init : Nav.Key -> Flags -> ( Model, Cmd Msg )
init key _ =
    ( { key = key, text = "" }, Cmd.none )


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
    Compress.encode model.text |> Maybe.map (Nav.load << twitterSharingUrl) |> Maybe.withDefault Cmd.none


twitterSharingUrl : String -> String
twitterSharingUrl text =
    UB.crossOrigin "https://twitter.com" [ "intent", "tweet" ] [ UB.string "text" text ]


view : Model -> Html Msg
view _ =
    div []
        [ button [ onClick Tweet ] [ text "Tweet" ]
        , textarea [ onInput Edit ] []
        ]
