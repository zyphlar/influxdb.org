/*!
 * jQuery Cookie Plugin v1.3
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2011, Klaus Hartl
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/GPL-2.0
 *
 * Modified to work with Zepto.js by ZURB
 */
!function(t,e,n){function r(t){return t}function i(t){return decodeURIComponent(t.replace(a," "))}var a=/\+/g,o=t.cookie=function(a,s,u){if(s!==n){if(u=t.extend({},o.defaults,u),null===s&&(u.expires=-1),"number"==typeof u.expires){var c=u.expires,l=u.expires=new Date;l.setDate(l.getDate()+c)}return s=o.json?JSON.stringify(s):String(s),e.cookie=[encodeURIComponent(a),"=",o.raw?s:encodeURIComponent(s),u.expires?"; expires="+u.expires.toUTCString():"",u.path?"; path="+u.path:"",u.domain?"; domain="+u.domain:"",u.secure?"; secure":""].join("")}for(var f=o.raw?r:i,h=e.cookie.split("; "),d=0,p=h.length;p>d;d++){var g=h[d].split("=");if(f(g.shift())===a){var m=f(g.join("="));return o.json?JSON.parse(m):m}}return null};o.defaults={},t.removeCookie=function(e,n){return null!==t.cookie(e)?(t.cookie(e,null,n),!0):!1}}(Foundation.zj,document);