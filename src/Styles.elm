module Styles exposing (..)

import Dict exposing (Dict)
import Html.Attributes exposing (style)


title =
    style
        [ ( "text-align", "center" )
        ]


score =
    style
        [ ( "text-align", "center" )
        , ( "font-size", "16px" )
        , ( "font-weight", "bold" )
        , ( "margin", "10px" )
        ]


grid =
    style
        [ ( "margin", "0 auto" )
        , ( "width", "400px" )
        , ( "box-sizing", "border-box" )
        ]


cell =
    style
        [ ( "line-height", "100px" )
        , ( "font-size", "55px" )
        , ( "font-weight", "bold" )
        , ( "height", "100px" )
        , ( "width", "100px" )
        , ( "float", "left" )
        , ( "border", "solid 1px #FF0000" )
        , ( "text-align", "center" )
        , ( "background-color", "rgba(238, 228, 218, 0.35)" )
        , ( "box-sizing", "border-box" )
        ]


tiles =
    Dict.fromList
        [ ( 2, style [ ( "background-color", "#EEE4DA" ) ] )
        , ( 4, style [ ( "background-color", "#EEE4DA" ) ] )
        ]



--
-- .tile-2 {
-- 	background-color: #EEE4DA;
-- }
--
-- .tile-4 {
-- 	background-color: #EDE0C8;
-- }
--
-- .tile-8 {
-- 	background-color: #F2B179;
-- }
--
-- .tile-16 {
-- 	background-color: #F59563;
-- }
--
-- .tile-32 {
-- 	background-color: #F67C5F;
-- }
--
-- .tile-64 {
-- 	background-color: #F65E3B;
-- }
--
-- .tile-128 {
-- 	background-color: #EDCF72;
-- 	font-size: 45px;
-- }
--
-- .tile-256 {
-- 	background-color: #EDCC61;
-- 	font-size: 45px;
-- }
--
-- .tile-512 {
-- 	background-color: #EDC850;
-- 	font-size: 45px;
-- }
--
-- .tile-1024 {
-- 	background-color: #EDC53F;
-- 	font-size: 35px;
-- }
--
-- .tile-2048 {
-- 	background-color: #EDC22E;
-- 	font-size: 35px;
-- }
