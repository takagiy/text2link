module Route.Show exposing (Flags, Model, Msg, Options, init, update, view)

import Browser.Navigation as Nav
import Compress
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import OutMsg exposing (OutMsg)
import Ref
import Task
import Time exposing (Posix)
import Url exposing (Url)


type alias Model =
    { text : String
    , date : Maybe String
    , url : Url
    , key : Nav.Key
    }


type Msg
    = Noop
    | Edit
    | EditWith
    | DatePrepared DateInfo


type alias Flags =
    String


type alias Options =
    Maybe ()


type alias DateInfo =
    { raw : Maybe Posix
    , zone : Time.Zone
    }


init : Url -> Nav.Key -> Flags -> Options -> ( Model, Cmd Msg )
init url key flags _ =
    let
        data =
            Compress.decode flags

        date =
            Maybe.map Tuple.first data
    in
    ( { text =
            data |> Maybe.map Tuple.second |> Maybe.withDefault ""
      , date = Nothing
      , url = url
      , key = key
      }
    , Task.perform DatePrepared (Task.map (DateInfo date) Time.here)
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

        DatePrepared info ->
            ( { model | date = formatDate info.zone info.raw }, Cmd.none, OutMsg.Noop )


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
            , viewDate model.date
            , div
                [ class "container-text" ]
                [ div [ class "text" ] [ text model.text ]
                ]
            ]
        ]


viewDate : Maybe String -> Html Msg
viewDate date =
    case date of
        Just d ->
            div
                [ class "container-time" ]
                [ span [ class "time" ] [ text d ] ]

        _ ->
            text ""


formatDate : Time.Zone -> Maybe Posix -> Maybe String
formatDate zone date =
    case date of
        Just d ->
            Just
                ("at "
                    ++ (Time.toHour zone d |> String.fromInt)
                    ++ ":"
                    ++ (Time.toMinute zone d |> String.fromInt |> padZero)
                    ++ ", "
                    ++ formatMonth zone d
                    ++ " "
                    ++ (Time.toDay zone d |> String.fromInt)
                    ++ ", "
                    ++ (Time.toYear zone d |> String.fromInt)
                )

        _ ->
            Nothing


formatMonth : Time.Zone -> Posix -> String
formatMonth zone date =
    (case Time.toMonth zone date of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"
    )
        ++ "."


padZero : String -> String
padZero =
    String.padLeft 2 '0'
