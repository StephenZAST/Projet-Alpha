import { Request, Response } from 'express';
import { OrderItemService } from '../services/order.service/orderItem.service';

export class OrderItemController {
  static async createOrderItem(req: Request, res: Response) {
    try {
      const orderItemData = req.body;
      const result = await OrderItemService.createOrderItem(orderItemData);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

    static async getOrderItemById(req: Request, res: Response) {
    try {
      const orderItemId = req.params.orderItemId;
      const result = await OrderItemService.getOrderItemById(orderItemId);
      res.json({ data: result });
    } catch (error: any) {
        res.status(error.message === 'Order item not found' ? 404 : 500)
            .json({ error: error.message });
    }
  }

  static async getAllOrderItems(req: Request, res: Response) {
    try {
      const result = await OrderItemService.getAllOrderItems();
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getOrderItemsByOrderId(req: Request, res: Response) {
    try {
      const orderId = req.params.orderId;
      const result = await OrderItemService.getOrderItemsByOrderId(orderId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateOrderItem(req: Request, res: Response) {
    try {
      const orderItemId = req.params.orderItemId;
      const orderItemData = req.body;
      const result = await OrderItemService.updateOrderItem(orderItemId, orderItemData);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteOrderItem(req: Request, res: Response) {
    try {
      const orderItemId = req.params.orderItemId;
      await OrderItemService.deleteOrderItem(orderItemId);
      res.json({ message: 'Order item deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}