module Route.Show exposing (Flags, Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)


type alias Model =
    { text : String }


type Msg
    = Noop


type alias Flags =
    String


init : Nav.Key -> Flags -> ( Model, Cmd Msg )
init _ flags =
    ( { text =
            flags |> Compress.decode |> Maybe.withDefault ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    h1 [] [ text model.text ]
