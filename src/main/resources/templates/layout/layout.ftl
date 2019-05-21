<#assign basePath = request.contextPath />
<!DOCTYPE html>
<#macro Head title charset="utf-8" lang="zh-CN">
<html lang="${lang}">
<head>
    <title>${title}</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta http-equiv="Access-Control-Allow-Origin" content="*">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="format-detection" content="telephone=no">
    <meta charset="${charset}"/>
    <base href="${basePath!}/">
    <link rel="icon" href="${basePath!}/static/img/logo.png">
    <link href="${basePath!}/static/layui/css/layui.css" type="text/css" media="screen" rel="stylesheet"/>
    <link rel="stylesheet" href="${basePath!}/static/css/public.css" media="all" />
    <link rel="stylesheet" href="${basePath!}/static/css/index.css" media="all" />
    <script src="${basePath!}/static/js/jquery.min.js" type="text/javascript"></script>
    <script src="${basePath!}/static/layui/layui.js" type="text/javascript"></script>
    <script src="${basePath!}/static/js/common.js" type="text/javascript"></script>
    <script src="${basePath!}/static/js/admin.js" type="text/javascript"></script>
<#nested>
</head>
</#macro>
<#macro Body>
<body>
<#nested>
</body>
</html>
</#macro>