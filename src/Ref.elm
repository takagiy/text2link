module Ref exposing (editorUrl)

import Url exposing (Url)


editorUrl : Url -> Url
editorUrl url =
    { url | query = Nothing }
