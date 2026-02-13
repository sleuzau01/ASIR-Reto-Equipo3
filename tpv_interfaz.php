<?php
/**
 * Template Name: TPV Bar Full
 */

if (!defined('ABSPATH')) exit;
if (!session_id()) session_start();

global $wpdb;

// ========== OBTENER BAR_ID DE LA URL ==========
$bar_id = isset($_GET['bar_id']) ? intval($_GET['bar_id']) : 0;

if ($bar_id < 1 || $bar_id > 16) {
    die('<h1 style="color:red;text-align:center;margin-top:50px;">❌ ERROR: Bar ID inválido. URL correcta: ?bar_id=1 a ?bar_id=16</h1>');
}

$bar_info = $wpdb->get_row($wpdb->prepare("SELECT * FROM bares WHERE id = %d", $bar_id));

if (!$bar_info) {
    die('<h1 style="color:red;text-align:center;margin-top:50px;">❌ ERROR: Bar no encontrado en la base de datos</h1>');
}

$_SESSION['tpv_bar_id'] = $bar_id;
$_SESSION['tpv_bar_name'] = $bar_info->nombre;

// ========== PROCESAR AJAX ==========
if (isset($_POST['ajax_action'])) {
    header('Content-Type: application/json');
    
    switch ($_POST['ajax_action']) {
        case 'select_user':
            $user_id = intval($_POST['user_id']);
            $user = $wpdb->get_row($wpdb->prepare(
                "SELECT u.*, r.nombre as rol_nombre FROM usuarios u 
                 JOIN roles r ON u.rol_id = r.id WHERE u.id = %d AND u.activo = 1",
                $user_id
            ));
            
            if ($user) {
                $_SESSION['tpv_user_id'] = $user->id;
                $_SESSION['tpv_user_name'] = $user->nombre_completo;
                $_SESSION['tpv_cart'] = array();
                echo json_encode(['success' => true, 'user' => $user->nombre_completo]);
            } else {
                echo json_encode(['success' => false, 'error' => 'Usuario no válido']);
            }
            exit;
            
        case 'add_product':
            if (!isset($_SESSION['tpv_user_id'])) {
                echo json_encode(['success' => false, 'error' => 'Selecciona usuario primero']);
                exit;
            }
            
            $product_id = intval($_POST['product_id']);
            $product = $wpdb->get_row($wpdb->prepare(
                "SELECT * FROM productos WHERE id = %d AND activo = 1",
                $product_id
            ));
            
            if ($product) {
                if (!isset($_SESSION['tpv_cart'])) {
                    $_SESSION['tpv_cart'] = array();
                }
                
                $found = false;
                foreach ($_SESSION['tpv_cart'] as &$item) {
                    if ($item['id'] == $product_id) {
                        $item['quantity']++;
                        $found = true;
                        break;
                    }
                }
                
                if (!$found) {
                    $_SESSION['tpv_cart'][] = array(
                        'id' => $product->id,
                        'name' => $product->nombre,
                        'price' => floatval($product->precio_base),
                        'quantity' => 1
                    );
                }
                
                echo json_encode(['success' => true, 'cart' => $_SESSION['tpv_cart']]);
            } else {
                echo json_encode(['success' => false, 'error' => 'Producto no disponible']);
            }
            exit;
            
        case 'remove_product':
            $product_id = intval($_POST['product_id']);
            
            if (isset($_SESSION['tpv_cart'])) {
                foreach ($_SESSION['tpv_cart'] as $key => $item) {
                    if ($item['id'] == $product_id) {
                        unset($_SESSION['tpv_cart'][$key]);
                        $_SESSION['tpv_cart'] = array_values($_SESSION['tpv_cart']);
                        break;
                    }
                }
            }
            
            echo json_encode(['success' => true, 'cart' => $_SESSION['tpv_cart']]);
            exit;
            
        case 'confirm_sale':
            if (!isset($_SESSION['tpv_user_id']) || empty($_SESSION['tpv_cart'])) {
                echo json_encode(['success' => false, 'error' => 'Carrito vacío']);
                exit;
            }
            
            $payment_method = sanitize_text_field($_POST['payment_method']);
            $total = 0;
            
            foreach ($_SESSION['tpv_cart'] as $item) {
                $total += $item['price'] * $item['quantity'];
            }
            
            $wpdb->insert(
                'ventas',
                array(
                    'bar_id' => $_SESSION['tpv_bar_id'],
                    'usuario_id' => $_SESSION['tpv_user_id'],
                    'metodo_pago' => $payment_method,
                    'total' => $total,
                    'numero_transaccion' => 'TX' . $_SESSION['tpv_bar_id'] . '-' . time(),
                    'estado' => 'Completada'
                ),
                array('%d', '%d', '%s', '%f', '%s', '%s')
            );
            
            $venta_id = $wpdb->insert_id;
            
            foreach ($_SESSION['tpv_cart'] as $item) {
                $wpdb->insert(
                    'ventas_detalle',
                    array(
                        'venta_id' => $venta_id,
                        'producto_id' => $item['id'],
                        'cantidad' => $item['quantity'],
                        'precio_unitario' => $item['price']
                    ),
                    array('%d', '%d', '%d', '%f')
                );
            }
            
            $_SESSION['tpv_cart'] = array();
            
            echo json_encode([
                'success' => true,
                'ticket' => $venta_id,
                'total' => number_format($total, 2) . '€'
            ]);
            exit;
            
        case 'reset':
            unset($_SESSION['tpv_user_id']);
            unset($_SESSION['tpv_user_name']);
            unset($_SESSION['tpv_cart']);
            echo json_encode(['success' => true]);
            exit;
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TPV - <?php echo esc_html($bar_info->nombre); ?></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            overflow: hidden;
            height: 100vh;
        }
        
        .tpv-container {
            width: 100vw;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .tpv-screen {
            display: none;
            flex-direction: column;
            width: 100%;
            height: 100%;
            padding: 20px;
            overflow-y: auto;
        }
        
        .tpv-screen.active {
            display: flex;
        }
        
        .tpv-header {
            background: rgba(255,255,255,0.95);
            padding: 15px 30px;
            border-radius: 15px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .bar-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .bar-badge {
            background: #667eea;
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            font-size: 1.1em;
        }
        
        .user-info {
            background: #27ae60;
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
        }
        
        h1 {
            color: #667eea;
            font-size: 2em;
        }
        
        .user-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 20px;
        }
        
        .user-card {
            background: white;
            padding: 40px 20px;
            border-radius: 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .user-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 12px 40px rgba(0,0,0,0.3);
        }
        
        .user-icon {
            font-size: 4em;
            margin-bottom: 15px;
        }
        
        .user-card h3 {
            color: #333;
            margin-bottom: 5px;
        }
        
        .user-card p {
            color: #666;
            font-size: 0.9em;
        }
        
        .content-wrapper {
            display: flex;
            gap: 20px;
            flex: 1;
            overflow: hidden;
        }
        
        .products-section {
            flex: 3;
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            padding: 20px;
            overflow-y: auto;
        }
        
        .category-title {
            color: #667eea;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
            margin: 20px 0 15px 0;
        }
        
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .product-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .product-card:hover {
            transform: scale(1.05);
            box-shadow: 0 8px 25px rgba(0,0,0,0.4);
        }
        
        .product-icon {
            font-size: 3em;
            margin-bottom: 10px;
        }
        
        .product-card h4 {
            font-size: 0.95em;
            margin: 10px 0;
        }
        
        .product-card .price {
            font-size: 1.4em;
            font-weight: bold;
        }
        
        .cart-section {
            flex: 1;
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            min-width: 300px;
        }
        
        .cart-section h3 {
            color: #667eea;
            margin-bottom: 15px;
        }
        
        #cart-items {
            flex: 1;
            overflow-y: auto;
            margin-bottom: 15px;
        }
        
        .cart-item {
            background: #f5f5f5;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .cart-item-info {
            flex: 1;
        }
        
        .cart-item-name {
            font-weight: bold;
            color: #333;
        }
        
        .cart-item-price {
            color: #667eea;
            font-size: 0.9em;
        }
        
        .btn-remove {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .btn-remove:hover {
            background: #c0392b;
        }
        
        .cart-total {
            background: #667eea;
            color: white;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            font-size: 1.5em;
            margin-bottom: 15px;
        }
        
        .btn-primary, .btn-secondary {
            padding: 15px;
            border: none;
            border-radius: 25px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            width: 100%;
            margin-bottom: 10px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover:not(:disabled) {
            transform: scale(1.02);
            box-shadow: 0 8px 20px rgba(102,126,234,0.4);
        }
        
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .btn-secondary {
            background: #95a5a6;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #7f8c8d;
        }
        
        .payment-options {
            display: flex;
            gap: 40px;
            justify-content: center;
            padding: 60px;
        }
        
        .payment-card {
            background: white;
            padding: 60px 40px;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            min-width: 250px;
        }
        
        .payment-card:hover {
            transform: translateY(-15px);
            box-shadow: 0 15px 50px rgba(0,0,0,0.3);
        }
        
        .payment-icon {
            font-size: 6em;
            margin-bottom: 20px;
        }
        
        .payment-card h3 {
            font-size: 1.8em;
            color: #333;
        }
        
        .payment-summary {
            background: rgba(255,255,255,0.95);
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            max-width: 400px;
            margin: 0 auto;
        }
        
        .payment-summary h3 {
            color: #667eea;
            margin-bottom: 20px;
        }
        
        .payment-summary p {
            font-size: 1.3em;
            margin: 15px 0;
        }
        
        .confirmation-content {
            background: white;
            padding: 80px 60px;
            border-radius: 20px;
            text-align: center;
            margin: auto;
            max-width: 600px;
        }
        
        .success-icon {
            font-size: 8em;
            margin-bottom: 20px;
            animation: bounce 0.5s ease;
        }
        
        @keyframes bounce {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.2); }
        }
        
        .confirmation-content h2 {
            color: #27ae60;
            font-size: 2.5em;
            margin: 20px 0;
        }
        
        .confirmation-content p {
            font-size: 1.4em;
            margin: 15px 0;
            color: #555;
        }
        
        .empty-cart {
            text-align: center;
            color: #999;
            padding: 40px 20px;
        }
    </style>
</head>
<body>

<div class="tpv-container">
    
    <div id="screen-users" class="tpv-screen active">
        <div class="tpv-header">
            <div class="bar-info">
                <h1>🏟️ RACING TPV</h1>
                <div class="bar-badge">
                    📍 <?php echo esc_html($bar_info->nombre); ?> (#<?php echo $bar_id; ?>)
                </div>
            </div>
        </div>
        
        <h2 style="color:white; text-align:center; margin-bottom:20px;">Selecciona tu Usuario</h2>
        
        <div class="user-grid">
            <?php
            $users = $wpdb->get_results("SELECT * FROM usuarios WHERE activo = 1 ORDER BY nombre_completo");
            foreach ($users as $user):
            ?>
            <div class="user-card" data-user-id="<?php echo $user->id; ?>">
                <div class="user-icon">👤</div>
                <h3><?php echo esc_html($user->nombre_completo); ?></h3>
                <p><?php echo esc_html($user->username); ?></p>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    
    <div id="screen-products" class="tpv-screen">
        <div class="tpv-header">
            <div class="bar-info">
                <div class="bar-badge">📍 <?php echo esc_html($bar_info->nombre); ?></div>
                <div class="user-info" id="current-user-display">👤 -</div>
            </div>
            <button id="btn-logout" class="btn-secondary" style="width:auto; padding:10px 20px;">🔙 Cambiar Usuario</button>
        </div>
        
        <div class="content-wrapper">
            <div class="products-section">
                <?php
                $products = $wpdb->get_results("SELECT * FROM productos WHERE activo = 1 ORDER BY categoria, nombre");
                
                $current_category = '';
                foreach ($products as $product):
                    if ($current_category != $product->categoria):
                        if ($current_category != '') echo '</div>';
                        $current_category = $product->categoria;
                        echo '<h3 class="category-title">' . esc_html($product->categoria) . '</h3>';
                        echo '<div class="product-grid">';
                    endif;
                    
                    $icon = $product->categoria == 'Bebida' ? '🥤' : '🍔';
                ?>
                <div class="product-card" data-product-id="<?php echo $product->id; ?>">
                    <div class="product-icon"><?php echo $icon; ?></div>
                    <h4><?php echo esc_html($product->nombre); ?></h4>
                    <p class="price"><?php echo number_format($product->precio_base, 2); ?>€</p>
                </div>
                <?php endforeach; ?>
                </div>
            </div>
            
            <div class="cart-section">
                <h3>🛒 Pedido Actual</h3>
                <div id="cart-items">
                    <div class="empty-cart">Carrito vacío</div>
                </div>
                <div class="cart-total">
                    <strong>TOTAL:</strong> <span id="cart-total">0.00€</span>
                </div>
                <button id="btn-confirm-order" class="btn-primary" disabled>✅ Confirmar Pedido</button>
            </div>
        </div>
    </div>
    
    <div id="screen-payment" class="tpv-screen">
        <div class="tpv-header">
            <h1>Método de Pago</h1>
        </div>
        
        <div class="payment-options">
            <div class="payment-card" data-method="Efectivo">
                <div class="payment-icon">💵</div>
                <h3>Efectivo</h3>
            </div>
            <div class="payment-card" data-method="Tarjeta">
                <div class="payment-icon">💳</div>
                <h3>Tarjeta</h3>
            </div>
        </div>
        
        <div class="payment-summary">
            <h3>Resumen del Pedido</h3>
            <p>Total a pagar: <strong id="payment-total">0.00€</strong></p>
            <button id="btn-back-products" class="btn-secondary">🔙 Volver a Productos</button>
        </div>
    </div>
    
    <div id="screen-confirmation" class="tpv-screen">
        <div class="confirmation-content">
            <div class="success-icon">✅</div>
            <h2>¡Venta Completada!</h2>
            <p>Ticket Nº: <strong id="ticket-number">-</strong></p>
            <p>Total: <strong id="confirm-total">-</strong></p>
            <p style="color:#999; font-size:0.9em; margin-top:20px;">
                Bar: <?php echo esc_html($bar_info->nombre); ?>
            </p>
            <button id="btn-new-sale" class="btn-primary" style="margin-top:30px;">🔄 Nueva Venta</button>
        </div>
    </div>
    
</div>

<script>
(function() {
    let currentCart = [];
    
    function showScreen(screenId) {
        document.querySelectorAll('.tpv-screen').forEach(s => s.classList.remove('active'));
        document.getElementById(screenId).classList.add('active');
    }
    
    function ajax(action, data, callback) {
        const formData = new FormData();
        formData.append('ajax_action', action);
        for (let key in data) {
            formData.append(key, data[key]);
        }
        
        fetch(window.location.href, {
            method: 'POST',
            body: formData
        })
        .then(r => r.json())
        .then(callback)
        .catch(e => alert('Error: ' + e));
    }
    
    document.querySelectorAll('.user-card').forEach(card => {
        card.addEventListener('click', function() {
            const userId = this.dataset.userId;
            ajax('select_user', {user_id: userId}, function(res) {
                if (res.success) {
                    document.getElementById('current-user-display').textContent = '👤 ' + res.user;
                    showScreen('screen-products');
                    updateCart();
                } else {
                    alert(res.error);
                }
            });
        });
    });
    
    document.querySelectorAll('.product-card').forEach(card => {
        card.addEventListener('click', function() {
            const productId = this.dataset.productId;
            ajax('add_product', {product_id: productId}, function(res) {
                if (res.success) {
                    currentCart = res.cart;
                    updateCart();
                } else {
                    alert(res.error);
                }
            });
        });
    });
    
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('btn-remove')) {
            const productId = e.target.dataset.productId;
            ajax('remove_product', {product_id: productId}, function(res) {
                if (res.success) {
                    currentCart = res.cart;
                    updateCart();
                }
            });
        }
    });
    
    document.getElementById('btn-confirm-order').addEventListener('click', function() {
        if (currentCart.length > 0) {
            const total = calculateTotal();
            document.getElementById('payment-total').textContent = total.toFixed(2) + '€';
            showScreen('screen-payment');
        }
    });
    
    document.querySelectorAll('.payment-card').forEach(card => {
        card.addEventListener('click', function() {
            const method = this.dataset.method;
            if (!confirm('¿Confirmar venta con ' + method + '?')) return;
            
            ajax('confirm_sale', {payment_method: method}, function(res) {
                if (res.success) {
                    document.getElementById('ticket-number').textContent = res.ticket;
                    document.getElementById('confirm-total').textContent = res.total;
                    showScreen('screen-confirmation');
                    currentCart = [];
                    updateCart();
                } else {
                    alert(res.error);
                }
            });
        });
    });
    
    document.getElementById('btn-back-products').addEventListener('click', () => showScreen('screen-products'));
    
    document.getElementById('btn-new-sale').addEventListener('click', function() {
        ajax('reset', {}, function() {
            showScreen('screen-users');
            currentCart = [];
        });
    });
    
    document.getElementById('btn-logout').addEventListener('click', function() {
        if (confirm('¿Cambiar de usuario? Se perderá el pedido actual.')) {
            ajax('reset', {}, function() {
                showScreen('screen-users');
                currentCart = [];
            });
        }
    });
    
    function updateCart() {
        const cartEl = document.getElementById('cart-items');
        cartEl.innerHTML = '';
        
        if (currentCart.length === 0) {
            cartEl.innerHTML = '<div class="empty-cart">Carrito vacío</div>';
            document.getElementById('btn-confirm-order').disabled = true;
        } else {
            currentCart.forEach(item => {
                const subtotal = (item.price * item.quantity).toFixed(2);
                const div = document.createElement('div');
                div.className = 'cart-item';
                div.innerHTML = `
                    <div class="cart-item-info">
                        <div class="cart-item-name">${item.name} ×${item.quantity}</div>
                        <div class="cart-item-price">${subtotal}€</div>
                    </div>
                    <button class="btn-remove" data-product-id="${item.id}">❌</button>
                `;
                cartEl.appendChild(div);
            });
            document.getElementById('btn-confirm-order').disabled = false;
        }
        
        const total = calculateTotal();
        document.getElementById('cart-total').textContent = total.toFixed(2) + '€';
    }
    
    function calculateTotal() {
        return currentCart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    }
})();
</script>

</body>
</html>
