#= require vendor/zepto
#= require vendor/custom.modernizr
#= require vendor/foundation
#= require_self

$(document).foundation()

$ ->
  $("div.section-container#docs a").each (index, el) =>
    if el.attributes.href.value == window.location.pathname
      item = $(el)
      item.parents("section").addClass("active")
      item.addClass("active")
