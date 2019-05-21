package com.manager.service.dto.role;

import com.manager.entity.Role;

import java.util.List;

public class RoleListResponse {
    private int count;
    private List<Role> items;

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public List<Role> getItems() {
        return items;
    }

    public void setItems(List<Role> items) {
        this.items = items;
    }
}
