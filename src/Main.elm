module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import OutMsg exposing (OutMsg)
import Ref
import Route
import Route.Edit as Edit
import Route.Show as Show
import Task
import Url exposing (Url)


type alias Model =
    { key : Nav.Key
    , url : Url
    , options : Maybe Route.Options
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
            initRoute url key Nothing (Route.route url)
    in
    ( { key = key
      , url = url
      , options = Nothing
      , model = model
      }
    , cmd
    )


initRoute : Url -> Nav.Key -> Maybe Route.Options -> Route.Route -> ( RoutedModel, Cmd Msg )
initRoute url key options route =
    case route of
        Route.Edit flags ->
            Edit.init url key flags (options |> Maybe.andThen Route.getEditOptions) |> fix EditModel (RoutedMsg << EditMsg)

        Route.Show flags ->
            Show.init url key flags (options |> Maybe.andThen Route.getShowOptions) |> fix ShowModel (RoutedMsg << ShowMsg)


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
                ( newModel, cmd, outMsg ) =
                    updateRoute m model.model
            in
            updateOut outMsg ( { model | model = newModel }, cmd )

        Go url ->
            let
                ( m, cmd ) =
                    initRoute url model.key model.options (Route.route url)
            in
            ( { model | model = m }, cmd )


updateOut : OutMsg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateOut msg ( model, cmd ) =
    case msg of
        OutMsg.Noop ->
            ( model, cmd )

        OutMsg.EditWith text ->
            ( { model | options = Just (Route.EditOptions (Just text)) }
            , Cmd.batch
                [ cmd
                , Nav.pushUrl model.key (Ref.editorUrl model.url |> Url.toString)
                ]
            )


updateRoute : RoutedMsg -> RoutedModel -> ( RoutedModel, Cmd Msg, OutMsg )
updateRoute msg model =
    case ( msg, model ) of
        ( EditMsg m, EditModel md ) ->
            Edit.update m md |> fix3 EditModel (RoutedMsg << EditMsg)

        ( ShowMsg m, ShowModel md ) ->
            Show.update m md |> fix3 ShowModel (RoutedMsg << ShowMsg)

        _ ->
            ( model, Cmd.none, OutMsg.Noop )


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    case request of
        Browser.Internal url ->
            Go url

        Browser.External url ->
            Invoke (Nav.load url)


onUrlChange : Url -> Msg
onUrlChange url =
    Go url


fixCmd : (a -> msg) -> ( model, Cmd a ) -> ( model, Cmd msg )
fixCmd f =
    Tuple.mapSecond (Cmd.map f)


fix : (a -> model) -> (b -> msg) -> ( a, Cmd b ) -> ( model, Cmd msg )
fix f g x =
    x |> Tuple.mapFirst f |> fixCmd g


fix3 : (a -> model) -> (b -> msg) -> ( a, Cmd b, OutMsg ) -> ( model, Cmd msg, OutMsg )
fix3 f g ( a, b, c ) =
    let
        ( x, y ) =
            fix f g ( a, b )
    in
    ( x, y, c )
