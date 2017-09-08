module Pages.Dojo.State exposing (..)

import Game.State as Game
import Game.Types as GameTypes
import Pages.Dojo.Menu as Menu
import Pages.Dojo.Types exposing (..)
import Response exposing (..)


initialModel : Model
initialModel =
    { game = Game.initialModel
    , menu = Menu.init
    }


initalCommands : Cmd Msg
initalCommands =
    Cmd.batch
        [ Cmd.none ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MenuMsg (Menu.subscriptions model.menu) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        MenuMsg subaction ->
            let
                midModel =
                    { model | menu = Menu.update subaction model.menu }
            in
                case subaction of
                    Menu.OutMsg state ->
                        Game.update (GameTypes.StartGameMsg midModel.menu.numberOfPlayers) midModel.game
                            |> mapModel (\x -> { midModel | game = x })
                            |> mapCmd GameMsg

                    Menu.InMsg secret ->
                        ( midModel, Cmd.none )

        GameMsg subaction ->
            Game.update subaction model.game
                |> mapModel (\x -> { model | game = x })
                |> mapCmd GameMsg
