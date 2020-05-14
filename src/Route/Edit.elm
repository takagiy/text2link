module Route.Edit exposing (Flags, Model, Msg, init, update, view)

import Html exposing (..)
import Html.Events exposing (..)


type alias Model =
    { text : String }


type Msg
    = Noop
    | Edit String


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { text = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( case msg of
        Noop ->
            model

        Edit text ->
            { model | text = text }
    , Cmd.none
    )


view : Model -> Html Msg
view _ =
    textarea [ onInput Edit ] []
