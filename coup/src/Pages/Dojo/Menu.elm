module Pages.Dojo.Menu exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown


init : Model
init =
    { modalState = Modal.visibleState
    , drop1State = Dropdown.initialState
    , numberOfPlayers = 3
    }


type alias Model =
    { modalState : Modal.State
    , drop1State : Dropdown.State
    , numberOfPlayers : Int
    }


type Msg
    = OutMsg Modal.State
    | InMsg SecretMsg


type SecretMsg
    = Drop1Msg Dropdown.State
    | PlayerSelectMsg1
    | PlayerSelectMsg2
    | PlayerSelectMsg3
    | PlayerSelectMsg4
    | PlayerSelectMsg5


update : Msg -> Model -> Model
update action model =
    case action of
        OutMsg state ->
            { model | modalState = state }

        InMsg subaction ->
            case subaction of
                Drop1Msg state ->
                    { model | drop1State = state }

                PlayerSelectMsg1 ->
                    { model | numberOfPlayers = 1 }

                PlayerSelectMsg2 ->
                    { model | numberOfPlayers = 2 }

                PlayerSelectMsg3 ->
                    { model | numberOfPlayers = 3 }

                PlayerSelectMsg4 ->
                    { model | numberOfPlayers = 4 }

                PlayerSelectMsg5 ->
                    { model | numberOfPlayers = 5 }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map InMsg (Dropdown.subscriptions model.drop1State Drop1Msg) ]


view : Model -> Html Msg
view model =
    div []
        [ Modal.config OutMsg
            |> Modal.small
            |> Modal.h3 [] [ text "Welcome to the Dojo" ]
            |> Modal.body
                []
                [ p
                    []
                    [ text "How many opponents?" ]
                , dropdown model
                ]
            |> Modal.footer []
                [ Button.button
                    [ Button.success
                    , Button.attrs [ onClick <| OutMsg Modal.hiddenState ]
                    ]
                    [ text "Start!" ]
                ]
            |> Modal.view model.modalState
        ]


dropdown : Model -> Html Msg
dropdown model =
    div
        []
        [ Dropdown.dropdown
            model.drop1State
            { options = []
            , toggleMsg = Drop1Msg
            , toggleButton =
                Dropdown.toggle [ Button.primary, Button.small ] [ text (toString model.numberOfPlayers) ]
            , items =
                [ Dropdown.buttonItem [ onClick PlayerSelectMsg1 ] [ text "1" ]
                , Dropdown.buttonItem [ onClick PlayerSelectMsg2 ] [ text "2" ]
                , Dropdown.buttonItem [ onClick PlayerSelectMsg3 ] [ text "3" ]
                , Dropdown.buttonItem [ onClick PlayerSelectMsg4 ] [ text "4" ]
                , Dropdown.buttonItem [ onClick PlayerSelectMsg5 ] [ text "5" ]
                ]
            }
        ]
        |> Html.map InMsg
