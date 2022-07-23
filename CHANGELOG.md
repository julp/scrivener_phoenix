# Changelog

## 0.3.2 (2022-07-23)

* gettext dependency updated to 0.20
* automatically set `:live` option to `true` (if omitted) when the first argument of `Scrivener.PhoenixView.paginate/5` is a `%Phoenix.LiveView.Socket{}`

## 0.3.1 (2022-06-06)

fixed warning about collecting into a non-empty list

## 0.3.0 (2021-11-13)

added preliminar support for Live View by calling `Phoenix.LiveView.Helpers.live_patch/2` instead of `Phoenix.HTML.Link.link/2` if *live* option is `true`

## 0.2.1 (2021-11-11)

added option *display_if_single*

## 0.2.0 (2021-09-11)

added option *merge_params*

## 0.1.0 (2019-01-18)

public initial release
