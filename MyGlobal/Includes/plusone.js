window.___jsl=window.___jsl||{};
window.___jsl.h=window.___jsl.h||'r;gc\/23980661-3686120e';
window.___jsl.l=[];
window.___gpq=[];
window.gapi=window.gapi||{};
window.gapi.plusone=window.gapi.plusone||(function(){
  function f(n){return function(){window.___gpq.push(n,arguments)}}
  return{go:f('go'),render:f('render')}})();
function __bsld(){var p=window.gapi.plusone=window.googleapisv0.plusone;var f;while(f=window.___gpq.shift()){
  p[f]&&p[f].apply(p,window.___gpq.shift())}
}
window['___jsl'] = window['___jsl'] || {};window['___jsl']['u'] = 'https:\/\/apis.google.com\/js\/plusone.js';window['___jsl']['f'] = ['plusone-unsupported'];window['___jsl']['ms'] = 'https://plus.google.com';(window['___jsl']['ci'] = (window['___jsl']['ci'] || [])).push({});var gapi=window.gapi||{};
(function(){var o=void 0,w=void 0,x="___jsl",L="h",r="l",M="m",y="ms",z="cu",A="c",N="o",B="p",s="https://ssl.gstatic.com",O="/webclient/js",C="https://apis.google.com",D=".js",P="gcjs-3p",Q=/^(https?:)?\/\/([^/:@]*)(:[0-9]+)?(\/(\w|[-.,:!=/])*)(\?[^#]*)?(#.*)?$/,E=/^[?#]([^&]*&)*jsh=([^&]*)/,F="d",p="r",R="f",t="m",S="n",T="sync",U="callback",G="config",H="nodep",I="gapi.load: ",u=function(f,c){o&&o(f,c);throw I+f+(c&&" "+c);},J=function(f){w&&w(f);var c=window.console;(c=c&&c.warn)&&c(I+f)},K=function(f){f.sort();
for(var c=0;c<f.length;)!f[c]||c&&f[c]==f[c-1]?f.splice(c,1):++c},V=function(f){if(document.readyState!="loading")return false;if(typeof window.___gapisync!="undefined")return window.___gapisync;if(f&&(f=f[T],typeof f!="undefined"))return f;for(var f=document.getElementsByTagName("meta"),c=0,h;h=f[c];++c)if("generator"==h.getAttribute("name")&&"blogger"==h.getAttribute("content"))return true;return false},q=function(f,c){var h,i={};typeof c!=="function"?(i=c||{},h=i[U]):h=c;var j=window[x]=window[x]||
{},n=f.split(":");i[H]||K(n);var a=j[r]=j[r]||[];K(a);var d,e=window.location.search,g=window.location.hash;d=j[L];if(e=e&&E.exec(e)||g&&E.exec(g))try{d=decodeURIComponent(e[2])}catch(q){J("Invalid hint "+e[2])}d||u("No hint present","");for(var b,e=true,k=g=0,l;e&&(b=n[g])&&(l=a[k]);)b==l?++g:b<l&&(e=false),++k;b=e&&!b;if(!b){b=d.split(";");a:{d=n;var e=a,m=b,a=j,g=i;b=m.shift();l=b==p?s:b==t?a[y]||C:m.shift();b==p?(k=m.shift(),k=(k.indexOf("/")?O+"/":"")+k):k=m.shift();var o=b==F,v=o&&m.shift()||
P,m=o&&m.shift();if(b==F)g=k,k=v,v=m,d="/"+d.join(":")+(e.length?"!"+e.join(":"):"")+D+"?container="+k+"&c=2&jsload=0",g&&(d+="&r="+g),v=="d"&&(d+="&debug=1");else if(b==p||b==R)g=k,d=(g.indexOf("/")?"/":"")+g+"/"+d.join("__")+(e.length?"--"+e.join("__"):"")+D;else if(b==t||b==S)e=k,d=d.join(",").replace(/\./g,"_").replace(/-/g,"_"),d=e.replace("__features__",d),d=g[H]?d.replace("/d=1/","/d=0/"):d;else{J("Unknown hint type "+b);a="";break a}if(l){l+=d;d=l;g=Q.exec(d);if(!(e=!g))if(!(e=!!/\.\.|\/\//.test(g[4])))e=
d,g=g[2],b==p?a=e.substr(0,s.length)==s:b==t?(a=a[y]||C,a=e.substr(0,a.length)==a):(a=a[M],g&&a?(b=g.lastIndexOf(a),a=(b==0||a.charAt(0)=="."||g.charAt(b-1)==".")&&g.length-a.length==b):a=false),e=!a;e&&u("Invalid URI",d);a=l}else a=""}i[G]&&(j[z]=j[z]||[]).push(i[G]);if(a){h&&(j[B]=n,j[A]?u("Pending callback",a):(j[A]=h,j[N]=1));[].push.apply(j[r],n);V(i)?document.write('<script src="'+a+'"><\/script>'):(i=a,h=document.createElement("script"),h.setAttribute("src",i),i=document.getElementsByTagName("script")[0],
i.parentNode.insertBefore(h,i));return}}h&&(j[B]=n,h.call(null))};gapi.loader={load:q};gapi.load=q;(window.gapi=window.gapi||{}).load=q})();
gapi.load('plusone-unsupported', {'callback': window['__bsld']  });