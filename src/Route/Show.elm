module Route.Show exposing (Flags, Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Url exposing (Url)
import Url.Builder as UB


type alias Model =
    { text : String
    , url : Url
    , key : Nav.Key
    }


type Msg
    = Noop
    | Edit


type alias Flags =
    String


init : Url -> Nav.Key -> Flags -> ( Model, Cmd Msg )
init url key flags =
    ( { text =
            flags |> Compress.decode |> Maybe.withDefault ""
      , url = url
      , key = key
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        Edit ->
            ( model, Nav.pushUrl model.key (editorUrl model.url) )


editorUrl : Url -> String
editorUrl url =
    Url.toString { url | query = Nothing }


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
