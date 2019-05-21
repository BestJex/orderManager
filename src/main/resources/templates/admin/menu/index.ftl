<#include "../../layout/layout.ftl"/>
<@Head title="菜单管理">
<link rel="stylesheet" href="${basePath!}/static/css/ztree/bootstrapStyle/bootstrapStyle.css" type="text/css">
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.core.js"></script>
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.excheck.js"></script>
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.exedit.js"></script>
</@Head>
<@Body>
 <div class="layer">
     <div id="tableMain">
         <ul id="dataTree" class="ztree">
         </ul>
     </div>
 </div>

<#--带有 class="layui-fluid" 的容器中，那么宽度将不会固定，而是 100% 适应-->
<div id="addeditformdivid" hidden="" class="layui-fluid" style="margin: 15px;">
    <form class="layui-form" action="" id="addeditformid">
        <label hidden="true" id="editlabelid"></label>
        <input id="editid" name="id" value="" hidden/>
        <label hidden="true" id="editlabelpId"></label>
        <input id="pId" name="pId" value="" hidden/>
        <label hidden="true" id="tId"></label>
        <div class="layui-form-item">
            <label class="layui-form-label">图标</label>
            <div class="layui-input-block">
                <button class="layui-btn" id="choseIcon">选择图标</button>
                <input type="text" id="icon" name="icon" autocomplete="off" placeholder="请输入图标" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">菜单名称</label>
            <div class="layui-input-block">
                <input type="text" id="name" name="name" autocomplete="off" placeholder="请输入菜单名称" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">url</label>
            <div class="layui-input-block">
                <input type="text" id="url" name="url" autocomplete="off" placeholder="请输入url" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <div class="layui-input-block">
                <button class="layui-btn" lay-submit="" lay-filter="addeditsubmitfilter">立即提交</button>
                <button id="reset" type="reset" class="layui-btn layui-btn-primary">重置</button>
            </div>
        </div>

    </form>
</div>

<script>
var layerid;
//一般直接写在一个js文件中
layui.use(['layer', 'form','table'], function(){
    var layer = layui.layer
            ,form = layui.form
            ,$ = layui.$
            ,laytpl = layui.laytpl
            ,table = layui.table;

    pageInit();

    $("#choseIcon").click(function(){
        layer.open({
            type: 2,
            area:['95%', '95%'],
            content:'${basePath!}/static/icon/icons.html',
            shadeClose:true,
            end: function(){
                $("#icon").select();
            }
        });
        return false;
    });
});

function pageInit() {
    //监听提交(新增和编辑)
    layui.form.on('submit(addeditsubmitfilter)', function(data) {

        //为了防止form中的id值被点击重置后置空,将编辑的id存放在label中，在表单提交时从label中提取出值，赋给表单input
        $("#pId").val($("#editlabelpId").html());
        $("#editid").val($("#editlabelid").html());

        $.ajax({
            type: "POST",
            url:"admin/menu/addupdatemenu",
            data:$('#addeditformid').serialize(),
            async: false,
            error: function(request) {
                layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
            },
            success: function(res) {
                if(res.code == 0){
                    layer.alert("操作成功", {icon: 6}, function () {
                        window.location.reload();
                    })
                } else {
                    layer.alert(res.msg)
                }
            }
        });
        return false;
    });

    //初始化ztree(注意是-1)
    $.ajax({
        type: "POST",
        url:'admin/menu/loadCheckMenuInfo?parentId=-1',
        async: false,
        dataType: 'json',
        timeout: 1000,
        cache: false,
        error: function(request) {
            layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
        },
        success: function(data) {
           queryHandler(data);
        }
    });

    //初始化列表
    function queryHandler(zTreeNodes){
        // zTree 的参数配置，深入使用请参考 API 文档（setting 配置详解）
        var setting = {
            view: {
                showLine: false,
                addDiyDom: addDiyDom
            },
            //防止与ztree冲突，造成点击跳转
            data: {
                key: {
                    url: "xUrl"
                }
            }
        };
        //初始化树
        $.fn.zTree.init($("#dataTree"), setting, zTreeNodes);
        //添加表头
        var li_head = ' <li class="head"><div class="divTd" style="width:20%">菜单名称</div><div class="divTd" style="width:10%">菜单编号</div>' +
                '<div class="divTd" style="width:10%">父级编号</div><div class="divTd" style="width:20%">图标</div><div class="divTd" style="width:20%">链接地址</div>' +
                '<div class="divTd" style="width:20%">操作</div></li>';
        var rows = $("#dataTree").find('li');
        if (rows.length > 0) {
            rows.eq(0).before(li_head)
        } else {
            $("#dataTree").append(li_head);
            $("#dataTree").append('<li ><div style="text-align: center;line-height: 30px;" >无数据</div></li>')
        }
    }
    function opt(treeNode) {
        var htmlStr = '';
        //3级目录不可再增加子菜单
        if(treeNode.state!='3') {
            htmlStr += '<input type="button" class="addBtn" onclick="doAdd(\'' + treeNode.id + '\')" value="增加"/>';
        }
        htmlStr += '<input type="button" class="editBtn" onclick="doEdit(\'' + treeNode.id + '\')" value="编辑"/>';
        //主要菜单不提供删除
        if(treeNode.name!='系统菜单' && treeNode.name!='系统管理' && treeNode.name!='菜单管理' &&treeNode.name!='角色管理' &&treeNode.name!='用户管理' && treeNode.pId !='-1') {
            htmlStr += '<input type="button" class="delBtn" onclick="doDelete(\'' + treeNode.id + '\', \'' + treeNode.name + '\')" value="删除"/>';
        }
        return htmlStr;
    }

    /**
      * 自定义DOM节点
      */
    function addDiyDom(treeId, treeNode) {
        var spaceWidth = 15;
        var liObj = $("#" + treeNode.tId);
        var aObj = $("#" + treeNode.tId + "_a");
        var switchObj = $("#" + treeNode.tId + "_switch");
        var icoObj = $("#" + treeNode.tId + "_ico");
        var spanObj = $("#" + treeNode.tId + "_span");
        aObj.attr('title', '');
        aObj.append('<div class="divTd swich fnt" style="width:20%"></div>');
        var div = $(liObj).find('div').eq(0);
        //从默认的位置移除
        switchObj.remove();
        spanObj.remove();
        icoObj.remove();
        //在指定的div中添加
        div.append(switchObj);
        div.append(spanObj);
        //隐藏了层次的span
        var spaceStr = "<span style='height:1px;display: inline-block;width:" + (spaceWidth * treeNode.level) + "px'></span>";
        switchObj.before(spaceStr);
        //图标垂直居中
        icoObj.css("margin-top","9px");
        switchObj.after(icoObj);
        var editStr = '';
        //宽度需要和表头保持一致
        editStr += '<div class="divTd" style="width:10%">' + (treeNode.id) + '</div>';
        editStr += '<div class="divTd" style="width:10%">' + (treeNode.pId == null? '-1' : treeNode.pId) + '</div>';
        editStr += '<div class="divTd" style="width:20%"><i class="layui-icon" data-icon="' + treeNode.iconValue + '">' + treeNode.iconValue + '</i> </div>';
        editStr += '<div class="divTd" style="width:20%">' + (treeNode.url  == null ? '' : treeNode.url) + '</div>';
        editStr += '<div class="divTd" style="width:20%; text-align: center">' + opt(treeNode) + '</div>';
        aObj.append(editStr);
    }
}

// 增加菜单操作
function doAdd(treeNode) {
    //初始化新增表单
    $("#editlabelpId").html(treeNode);//设置父节点id，表单中仅需要提供父级节点的id即可，后台会根据pId查询
    $("#reset").click();//重置表单(新建时在进入表单前要重置一下表单的内容，不然表单打开后会显示上一次的表单的内容。这里调用表单中重置按钮的点击方法来重置)
    layerid=layer.open({//开启表单弹层
      /*  skin: 'layui-layer-molv',*/
        area:'30%',
        type: 1,
        title:'新建菜单',
        content: $('#addeditformdivid') //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响
    });
}

// 编辑菜单操作
function doEdit(treeNode) {
    //根据id获取菜单节点对象的数据并填充进编辑的表单中
    $.ajax({
        type: "POST",
        url:"admin/menu/info",
        data:{id:treeNode},
        async: false,
        error: function(request) {
            layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
        },
        success: function(res) {
            if(res.code == 0){
                $("#editlabelid").html(treeNode);//设置父节点id，表单中仅需要提供父级节点的id即可，后台会根据pId查询
                $("#icon").val(res.data.icon);
                $("#name").val(res.data.name);
                $("#url").val(res.data.url);
                layerid=layer.open({//开启表单弹层
                   /* skin: 'layui-layer-molv',*/
                    area:'60%',
                    type: 1,
                    title:'编辑菜单',
                    content: $('#addeditformdivid') //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响
                });
            } else {
                layer.alert(res.msg)
            }
        }
    });
}

//删除菜单操作
function doDelete(treeNode, name) {
    layer.alert("确认删除"+ name +"吗？", {icon: 3}, function () {
        layer.close(layer.index);
        $.ajax({
            type: "POST",
            url:"admin/menu/delete",
            data:{id:treeNode},
            async: false,
            error: function(request) {
                layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
            },
            success: function(res) {
                if(res.code == 0){
                    layer.alert("操作成功", {icon: 6}, function () {
                        window.location.reload();
                    })
                } else {
                    layer.alert(res.msg)
                }
            }
        });
    });
}
</script>

<style>
    body {
        overflow: auto;
    }
    .ztree *{
        font-family: "微软雅黑","宋体",Arial, "Times New Roman", Times, serif;
    }
    .ztree {
        width:100%;
        height:100%;
        overflow-y:auto;
        overflow-x:auto;
        border-left: 1px solid #E3E3E3;
        border-right: 1px solid #E3E3E3;
        border-bottom: 1px solid #E3E3E3;
        box-sizing: border-box;
    }
    .ztree li a {
        vertical-align: middle;
        height: 32px;
        padding: 0px;
    }
    .ztree li > a {
        width: 100%;
    }
    .ztree li a.curSelectedNode {
        padding-top: 0px;
        background-color: #FFE6B0;
        border: 1px #FFB951 solid;
        opacity: 1;
        height: 32px;
    }
    .ztree li ul {
        padding-left: 0px
    }
    .ztree div.divTd span {
        line-height: 30px;
        vertical-align: middle;
    }
    .ztree div.divTd {
        height: 100%;
        line-height: 30px;
        border-top: 1px solid #E3E3E3;
        border-left: 1px solid #E3E3E3;
        text-align: center;
        display: inline-block;
        color: #6c6c6c;
        overflow: hidden;
        box-sizing: border-box;
    }
    .ztree div.divTd:first-child {
        text-align: left;
        text-indent: 10px;
        border-left: none;
    }
    .ztree .head {
        background: #E8EFF5;
    }
    .ztree .head div.divTd {
        color: #393939;
        font-weight: bold;
    }
    .ztree .addBtn{
        margin: 0 5px;
        height: 22px;
        line-height: 22px;
        padding: 0 5px;
        font-size: 12px;
        display: inline-block;
        background-color: #009688;
        color: #fff;
        white-space: nowrap;
        text-align: center;
        border: none;
        border-radius: 2px;
        cursor: pointer;
    }
    .ztree .editBtn{
        margin: 0 5px;
        height: 22px;
        line-height: 22px;
        padding: 0 5px;
        font-size: 12px;
        display: inline-block;
        background-color: #FFB800;
        color: #fff;
        white-space: nowrap;
        text-align: center;
        border: none;
        border-radius: 2px;
        cursor: pointer;
    }
    .ztree .delBtn{
        margin: 0 5px;
        height: 22px;
        line-height: 22px;
        padding: 0 5px;
        font-size: 12px;
        display: inline-block;
        background-color: #FF5722;
        color: #fff;
        white-space: nowrap;
        text-align: center;
        border: none;
        border-radius: 2px;
        cursor: pointer;
    }
    li:nth-child(odd){
        background-color:#F5FAFA;
    }
    li:nth-child(even){
        background-color:#FFFFFF;
    }
</style>
</@Body>