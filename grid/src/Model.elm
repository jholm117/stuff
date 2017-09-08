module Model exposing (..)

import Array exposing (map)
import Controls
import Grid exposing (Coordinate, gridSize, setAsPlayer, setAsSpace)
import Keyboard exposing (KeyCode)
import Matrix exposing (toIndexedArray)
import Random exposing (Generator, generate)
import Random.Array exposing (choose)
import Response exposing (Response, mapBoth, mapCmd, mapModel, res, withCmd, withNone)
import Types exposing (..)


init : Response Model Msg
init =
    Model (Character Dead True) Grid.initModel []
        |> flip res initCom


initCom : Cmd Msg
initCom =
    Cmd.map GridMsg Grid.initCom


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs KeyMsg


update : Msg -> Model -> Response Model Msg
update msg model =
    case msg of
        GridMsg submsg ->
            { model | grid = Grid.update submsg model.grid }
                |> withNone

        KeyMsg keycode ->
            let
                ( player, grid ) =
                    movePlayer model.player keycode model.grid
            in
                { model | player = player, grid = grid }
                    |> withNone

        SpawnMsg isPlayer ->
            model |> withCmd (generate (SpawnedMsg isPlayer) <| spawn model.grid)

        SpawnedMsg isPlayer coordinate ->
            let
                pos =
                    Maybe.withDefault ( 15, 15 ) coordinate

                player =
                    Character (Alive pos) True
            in
                { model | player = player, grid = setAsPlayer pos model.grid }
                    |> withNone


movePlayer : Character -> KeyCode -> Grid.Model -> ( Character, Grid.Model )
movePlayer player keycode grid =
    case player.status of
        Dead ->
            ( player, grid )

        Alive oldPos ->
            let
                add1 int =
                    int + 1

                sub1 int =
                    int - 1

                newPos =
                    oldPos
                        |> case Controls.mapKeys keycode of
                            Up ->
                                Tuple.mapSecond sub1

                            Down ->
                                Tuple.mapSecond add1

                            Left ->
                                Tuple.mapFirst sub1

                            Right ->
                                Tuple.mapFirst add1

                            None ->
                                identity
            in
                if Grid.checkForWall grid newPos then
                    ( player, grid )
                else
                    ( { player | status = Alive newPos }, grid |> setAsSpace oldPos |> setAsPlayer newPos )


spawn : Grid.Model -> Generator (Maybe Coordinate)
spawn grid =
    grid
        |> Matrix.toIndexedArray
        |> Array.filter (\entry -> not <| Grid.isWall <| Tuple.second entry)
        |> Array.map (\entry -> Tuple.first entry)
        |> choose
        |> Random.map Tuple.first
