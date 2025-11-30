<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmation</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background-color: #4F46E5;
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 5px 5px 0 0;
        }
        .content {
            background-color: #f9f9f9;
            padding: 20px;
            border: 1px solid #ddd;
        }
        .order-details {
            background-color: white;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
        .order-items {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .order-items th {
            background-color: #f0f0f0;
            padding: 10px;
            text-align: left;
            border-bottom: 2px solid #ddd;
        }
        .order-items td {
            padding: 10px;
            border-bottom: 1px solid #eee;
        }
        .total {
            font-size: 18px;
            font-weight: bold;
            text-align: right;
            margin-top: 20px;
            padding: 10px;
            background-color: #f0f0f0;
            border-radius: 5px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Order Confirmation</h1>
    </div>

    <div class="content">
        <p>Dear {{ $order->customer_name }},</p>

        <p>Thank you for your order! We're pleased to confirm that we've received your order and it's being processed.</p>

        <div class="order-details">
            <h2>Order Details</h2>
            <p><strong>Order Number:</strong> #{{ $order->id }}</p>
            <p><strong>Order Date:</strong> {{ $order->created_at->format('F d, Y h:i A') }}</p>
            <p><strong>Status:</strong> {{ ucfirst($order->status) }}</p>
        </div>

        <div class="order-details">
            <h2>Shipping Information</h2>
            <p><strong>Name:</strong> {{ $order->customer_name }}</p>
            <p><strong>Email:</strong> {{ $order->customer_email }}</p>
            @if($order->customer_phone)
            <p><strong>Phone:</strong> {{ $order->customer_phone }}</p>
            @endif
            <p><strong>Shipping Address:</strong><br>{{ $order->shipping_address }}</p>
        </div>

        <h2>Order Items</h2>
        <table class="order-items">
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Subtotal</th>
                </tr>
            </thead>
            <tbody>
                @foreach($order->orderItems as $item)
                <tr>
                    <td>{{ $item->product->name }}</td>
                    <td>{{ $item->quantity }}</td>
                    <td>${{ number_format($item->price, 2) }}</td>
                    <td>${{ number_format($item->price * $item->quantity, 2) }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>

        <div class="total">
            Total: ${{ number_format($order->total, 2) }}
        </div>

        <p style="margin-top: 30px;">If you have any questions about your order, please don't hesitate to contact us.</p>

        <p>Thank you for shopping with us!</p>
    </div>

    <div class="footer">
        <p>&copy; {{ date('Y') }} Cinch E-Commerce. All rights reserved.</p>
    </div>
</body>
</html>

