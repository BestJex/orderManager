/*弹出层*/
/*
    参数解释：
    title   标题
    url     请求的url
    id      需要操作的数据id
    w       弹出层宽度（缺省调默认值）
    h       弹出层高度（缺省调默认值）
*/
function admin_show(title,url,w,h){
    if (title == null || title == '') {
        title=false;
    };
    if (url == null || url == '') {
        url="404.html";
    };
    if (w == null || w == '') {
        w=($(window).width()*0.9);
    };
    if (h == null || h == '') {
        h=($(window).height() - 50);
    };
    var index = layer.open({
        type: 2,
       /* skin: 'layui-layer-molv',*/
        area: [w+'px', h +'px'],
        fix: false, //不固定
        shadeClose: true,
        shade:0.4,
        title: title,
        content: url
    });
   /* layui.layer.full(index);
    //改变窗口大小时，重置弹窗的宽高，防止超出可视区域（如F12调出debug的操作）
    $(window).on("resize",function(){
        layui.layer.full(index);
    })*/
}

/*关闭弹出框口*/
function admin_close(){
    var index = parent.layer.getFrameIndex(window.name);
    parent.layer.close(index);
}
