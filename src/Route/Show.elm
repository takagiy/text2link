module Route.Show exposing (Flags, Model, Msg, init, update, view)

import Html exposing (..)


type alias Model =
    { text : String }


type Msg
    = Noop


type alias Flags =
    Maybe String


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { text = Maybe.withDefault "" flags }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    h1 [] [ text model.text ]
