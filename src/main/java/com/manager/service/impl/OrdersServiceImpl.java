package com.manager.service.impl;

import com.github.pagehelper.PageHelper;
import com.manager.entity.Orders;
import com.manager.entity.User;
import com.manager.mapper.OrdersMapper;
import com.manager.model.ExcelBean;
import com.manager.service.OrdersService;
import com.manager.util.DateUtils;
import com.manager.util.ExcelUtil;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import tk.mybatis.mapper.entity.Example;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.beans.IntrospectionException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.text.ParseException;
import java.util.*;

@Service("ordersService")
public class OrdersServiceImpl extends BaseService<Orders> implements OrdersService {

    @Resource
    private OrdersMapper ordersMapper;

    @Override
    public void importOrderExcel(InputStream in, MultipartFile file, HttpServletRequest request) throws Exception{

        String importNo = null;
        Object object = request.getSession().getAttribute("currentUser");
        if(object instanceof User) {
            User user = (User) object;
            importNo = String.format("%s_%s",user.getUserName(),System.currentTimeMillis());
        }

        List<List<Object>> listob = ExcelUtil.getBankListByExcel(in,file.getOriginalFilename());
        List<Orders> ordersList = new ArrayList<Orders>();
        //遍历listob数据，把数据放到List中
        for (int i = 0; i < listob.size() ; i++) {
            List<Object> ob = listob.get(i);
            Orders orders = new Orders();
            orders.setImportNo(importNo);
            //通过遍历实现把每一列封装成一个model中，再把所有的model用List集合装载
            orders.setTaskNo(String.valueOf(ob.get(0)));
            orders.setOrderNo(String.valueOf(ob.get(1)));
            orders.setShop(String.valueOf(ob.get(2)));
            orders.setTaobao(String.valueOf(ob.get(3)));
            orders.setEnPrice(Integer.valueOf(ob.get(4).toString())*100);
            orders.setRealPrice(Integer.valueOf(ob.get(5).toString())*100);
            orders.setStatus(Integer.valueOf(ob.get(6).toString()));
            orders.setSignStatus(Integer.valueOf(ob.get(7).toString()));
            orders.setEndTime(DateUtils.parseDate(ob.get(8).toString(),"yyyy-MM-dd"));
            ordersList.add(orders);
        }
        //批量插入
        ordersMapper.insertInfoBatch(ordersList);
    }

    @Override
    public XSSFWorkbook exportOrderExcel(String exportNo) throws InvocationTargetException, ClassNotFoundException, IntrospectionException, ParseException, IllegalAccessException {
        //根据条件查询数据，把数据装载到一个list中
        Example orderExample = new Example(Orders.class);
        List<Orders> orderList = this.selectByExample(orderExample);

        // 格式化查询出的数据
        List<Orders> orders = new ArrayList<>();
        for(Orders order:orderList) {
            Orders item = new Orders();
            item.setId(order.getId());
            item.setImportNo(order.getImportNo());
            item.setTaskNo(order.getTaskNo());
            item.setOrderNo(order.getOrderNo());
            item.setShop(order.getShop());
            item.setTaobao(order.getTaobao());
            item.setEnPrice(order.getEnPrice()/100);
            item.setRealPrice(order.getRealPrice()/100);
            item.setStatus(order.getStatus());
            item.setSignStatus(order.getSignStatus());
            item.setEndTime(order.getEndTime());
            orders.add(item);
        }

        List<ExcelBean> excel = new ArrayList<>();
        Map<Integer,List<ExcelBean>> map = new LinkedHashMap<>();
        XSSFWorkbook xssfWorkbook = null;
        //设置标题栏
        excel.add(new ExcelBean("序号","id",0));
        excel.add(new ExcelBean("导入编号","importNo",0));
        excel.add(new ExcelBean("任务编号","taskNo",0));
        excel.add(new ExcelBean("订单编号","orderNo",0));
        excel.add(new ExcelBean("店铺名","shop",0));
        excel.add(new ExcelBean("录入价格","enPrice",0));
        excel.add(new ExcelBean("实际价格","realPrice",0));
        excel.add(new ExcelBean("订单状态：1、代拍下，2、已拍下，3、已付款，4、其他","status",0));
        excel.add(new ExcelBean("标旗状态：1、等待标记，2、标记成功，3、标记失败，4、未订购应用","signStatus",0));
        excel.add(new ExcelBean("截止时间","endTime",0));
        map.put(0, excel);
        String sheetName = exportNo ;
        //调用ExcelUtil的方法
        xssfWorkbook = ExcelUtil.createExcelFile(Orders.class, orders, map, sheetName);
        return xssfWorkbook;
    }
}
