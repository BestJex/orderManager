package com.manager.service.dto.order;

import com.manager.entity.Orders;

import java.util.List;

public class OrderListResponse {
    private int count;
    private List<Orders> items;

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public List<Orders> getItems() {
        return items;
    }

    public void setItems(List<Orders> items) {
        this.items = items;
    }
}
