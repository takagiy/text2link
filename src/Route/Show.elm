module Route.Show exposing (Flags, Model, Msg, Options, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import OutMsg exposing (OutMsg)
import Ref
import Url exposing (Url)


type alias Model =
    { text : String
    , url : Url
    , key : Nav.Key
    }


type Msg
    = Noop
    | Edit
    | EditWith


type alias Flags =
    String


type alias Options =
    Maybe ()


init : Url -> Nav.Key -> Flags -> Options -> ( Model, Cmd Msg )
init url key flags _ =
    ( { text =
            flags |> Compress.decode |> Maybe.withDefault ""
      , url = url
      , key = key
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none, OutMsg.Noop )

        Edit ->
            ( model, Nav.pushUrl model.key (Ref.editorUrl model.url |> Url.toString), OutMsg.Noop )

        EditWith ->
            ( model, Cmd.none, OutMsg.EditWith model.text )


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
                    , onClick EditWith
                    ]
                    [ text "Edit" ]
                , button
                    [ class "button"
                    , onClick Edit
                    ]
                    [ text "New" ]
                ]
            , div
                [ class "container-text" ]
                [ div [ class "text" ] [ text model.text ]
                ]
            ]
        ]
