module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Route.Edit as Edit
import Route.Show as Show
import Url exposing (Url)


type alias Model =
    { key : Nav.Key
    , model : RoutedModel
    }


type RoutedModel
    = EditModel Edit.Model
    | ShowModel Show.Model


type Msg
    = Noop
    | Invoke (Cmd Msg)
    | RoutedMsg RoutedMsg
    | Go Url


type RoutedMsg
    = EditMsg Edit.Msg
    | ShowMsg Show.Msg


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( model, cmd ) =
            initRoute url key (Route.route url)
    in
    ( { key = key
      , model = model
      }
    , cmd
    )


initRoute : Url -> Nav.Key -> Route.Route -> ( RoutedModel, Cmd Msg )
initRoute url key route =
    case route of
        Route.Edit flags ->
            Edit.init url key flags |> fix EditModel (RoutedMsg << EditMsg)

        Route.Show flags ->
            Show.init url key flags |> fix ShowModel (RoutedMsg << ShowMsg)


view : Model -> Browser.Document Msg
view model =
    { title = "text2link"
    , body = [ viewRoute model ]
    }


viewRoute : Model -> Html Msg
viewRoute model =
    case model.model of
        EditModel m ->
            Edit.view m |> Html.map (RoutedMsg << EditMsg)

        ShowModel m ->
            Show.view m |> Html.map (RoutedMsg << ShowMsg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        Invoke cmd ->
            ( model, cmd )

        RoutedMsg m ->
            let
                ( newModel, cmd ) =
                    updateRoute m model.model
            in
            ( { model | model = newModel }, cmd )

        Go url ->
            let
                ( m, cmd ) =
                    initRoute url model.key (Route.route url)
            in
            ( { model | model = m }, cmd )


updateRoute : RoutedMsg -> RoutedModel -> ( RoutedModel, Cmd Msg )
updateRoute msg model =
    case ( msg, model ) of
        ( EditMsg m, EditModel md ) ->
            Edit.update m md |> fix EditModel (RoutedMsg << EditMsg)

        ( ShowMsg m, ShowModel md ) ->
            Show.update m md |> fix ShowModel (RoutedMsg << ShowMsg)

        _ ->
            ( model, Cmd.none )


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    case request of
        Browser.Internal url ->
            Go url

        Browser.External url ->
            Invoke (Nav.load url)


onUrlChange : Url -> Msg
onUrlChange _ =
    Noop


fixCmd : (a -> msg) -> ( model, Cmd a ) -> ( model, Cmd msg )
fixCmd f =
    Tuple.mapSecond (Cmd.map f)


fix : (a -> model) -> (b -> msg) -> ( a, Cmd b ) -> ( model, Cmd msg )
fix f g x =
    x |> Tuple.mapFirst f |> fixCmd g
