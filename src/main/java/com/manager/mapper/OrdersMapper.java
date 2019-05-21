package com.manager.mapper;

import com.manager.entity.Orders;
import com.manager.util.MyMapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface OrdersMapper extends MyMapper<Orders> {

    void insertInfoBatch(List<Orders> ordersList);

}