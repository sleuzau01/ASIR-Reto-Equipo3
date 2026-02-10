<?php
/**
 * Plugin Name: Racing DB TPV
 * Description: TPV para estadio Racing
 * Version: 1.1.1
 */

if (!defined('ABSPATH')) exit;

/* ===============================
   CREDENCIALES BD
   =============================== */
define('RACINGDB_HOST', 'racing-wordpress-db.c5t6z5r77jdj.us-east-1.rds.amazonaws.com:3306');
define('RACINGDB_USER', 'usuario2');
define('RACINGDB_PASS', '1234');



/* ===============================
   BD
   =============================== */
function racingdb_get_db(): ?wpdb {
    static $db = null;
    if ($db) return $db;

    $db = new wpdb(
        RACINGDB_USER,
        RACINGDB_PASS,
        'estadio_racing_bares',
        RACINGDB_HOST
    );

    if ($db->last_error) return null;
    $db->set_charset($db->dbh, 'utf8mb4');
    return $db;
}

/* ===============================
   SHORTCODE TPV
   =============================== */
add_shortcode('racing_tpv', function () {
    ob_start(); ?>
    <div id="racing-tpv">

        <!-- PASO 1 -->
        <div id="tpv-paso-empleado">
            <h1>Selecciona tu usuario</h1>
            <div id="tpv-empleados"></div>
        </div>

        <!-- PASO 2 -->
        <div id="tpv-paso-productos" style="display:none">
            <h1>Productos</h1>
            <div id="tpv-productos"></div>

            <h2>Ticket</h2>
            <div id="tpv-ticket"></div>
            <div id="tpv-total">Total: 0.00 €</div>

            <button id="tpv-ir-pago" class="tpv-btn">Continuar</button>
        </div>

        <!-- PASO 3 -->
        <div id="tpv-paso-pago" style="display:none">
            <h1>Método de pago</h1>
            <button class="tpv-pago" data-pago="Efectivo">EFECTIVO</button>
            <button class="tpv-pago" data-pago="Tarjeta">TARJETA</button>
        </div>

    </div>
    <?php
    return ob_get_clean();
});

/* ===============================
   AJAX TPV
   =============================== */
add_action('wp_ajax_racing_tpv_data', 'racing_tpv_data');
add_action('wp_ajax_nopriv_racing_tpv_data', 'racing_tpv_data');

function racing_tpv_data() {
    $db = racingdb_get_db();
if (!$db) {
    wp_send_json_error('No se pudo crear wpdb');
}

if ($db->last_error) {
    wp_send_json_error($db->last_error);
}


    $empleados = $db->get_results(
        "SELECT id, nombre_completo 
         FROM usuarios 
         WHERE activo = 1 AND rol_id IN (1,2,3)
         ORDER BY nombre_completo",
        ARRAY_A
    );

    $productos = $db->get_results(
        "SELECT 
            id,
            nombre,
            precio_base AS precio
         FROM productos
         WHERE activo = 1
         ORDER BY nombre",
        ARRAY_A
    );

    wp_send_json_success([
        'empleados' => $empleados,
        'productos' => $productos
    ]);
}



add_action('wp_ajax_racing_tpv_pagar', 'racing_tpv_pagar');
add_action('wp_ajax_nopriv_racing_tpv_pagar', 'racing_tpv_pagar');

function racing_tpv_pagar() {
    $db = racingdb_get_db();
if (!$db) {
    wp_send_json_error('No se pudo crear wpdb');
}

if ($db->last_error) {
    wp_send_json_error($db->last_error);
}


    $empleado = intval($_POST['empleado']);
    $metodo = sanitize_text_field($_POST['metodo']);
    $ticket = $_POST['ticket'];

    if (!$empleado || !$ticket || !is_array($ticket)) {
        wp_send_json_error('Datos incompletos');
    }

    // ⚠️ de momento bar fijo (luego lo mejoras)
    $bar_id = 1;

    // TOTAL
    $total = 0;
    foreach ($ticket as $i) {
        $total += floatval($i['precio']) * intval($i['cantidad']);
    }

    // INSERT VENTA
    $db->insert('ventas', [
        'bar_id' => $bar_id,
        'usuario_id' => $empleado,
        'metodo_pago' => $metodo,
        'total' => $total
    ]);

    $venta_id = $db->insert_id;
    if (!$venta_id) {
        wp_send_json_error('No se pudo crear la venta');
    }

    // INSERT LÍNEAS
    foreach ($ticket as $i) {
        $db->insert('ventas_detalle', [
            'venta_id' => $venta_id,
            'producto_id' => intval($i['id']),
            'cantidad' => intval($i['cantidad']),
            'precio_unitario' => floatval($i['precio'])
        ]);
    }

    wp_send_json_success([
        'venta_id' => $venta_id
    ]);
}





/* ===============================
   JS
   =============================== */
add_action('wp_enqueue_scripts', function () {

    wp_enqueue_script('jquery');

    wp_add_inline_script('jquery', '
        var tpvEmpleado = null;
        var tpvTicket = [];

        jQuery(function($){

            $.post("' . admin_url('admin-ajax.php') . '", {
                action: "racing_tpv_data"
            }, function(res){

                if(!res.success){
                    alert("Error cargando TPV");
                    return;
                }

                // EMPLEADOS
                res.data.empleados.forEach(function(e){
                    $("<button>")
                        .addClass("tpv-btn")
                        .text(e.nombre_completo)
                        .on("click", function(){
                            tpvEmpleado = e.id;
                            $("#tpv-paso-empleado").hide();
                            $("#tpv-paso-productos").show();
                        })
                        .appendTo("#tpv-empleados");
                });

                // PRODUCTOS
                res.data.productos.forEach(function(p){
                    $("<button>")
                        .addClass("tpv-btn")
                        .html(p.nombre + "<br>" + p.precio + " €")
                        .on("click", function(){
                            tpvAddProducto(p.id, p.nombre, p.precio);
                        })
                        .appendTo("#tpv-productos");
                });

            });

            $("#tpv-ir-pago").on("click", function(){
                if(tpvTicket.length === 0){
                    alert("Añade productos");
                    return;
                }
                $("#tpv-paso-productos").hide();
                $("#tpv-paso-pago").show();
            });

            $(".tpv-pago").on("click", function(){

    var metodo = $(this).data("pago");

    jQuery.post("' . admin_url('admin-ajax.php') . '", {
        action: "racing_tpv_pagar",
        empleado: tpvEmpleado,
        metodo: metodo,
        ticket: tpvTicket
    }, function(res){

        if(!res.success){
            alert("Error al guardar la venta");
            return;
        }

        alert("Venta registrada. ID: " + res.data.venta_id);

        // RESET TPV
        tpvTicket = [];
        jQuery("#tpv-ticket").html("");
        jQuery("#tpv-total").text("Total: 0.00 €");

        jQuery("#tpv-paso-pago").hide();
        jQuery("#tpv-paso-empleado").show();
    });

});


        });

        function tpvAddProducto(id, nombre, precio){
            var item = tpvTicket.find(i => i.id === id);
            if(item) item.cantidad++;
            else tpvTicket.push({id, nombre, precio, cantidad:1});
            tpvRenderTicket();
        }

        function tpvRenderTicket(){
    var total = 0;
    var html = "";

    tpvTicket.forEach(function(i, index){
        total += i.precio * i.cantidad;

        html += `
            <div style="display:flex;justify-content:space-between;align-items:center">
                <span>
                    ${i.nombre} x${i.cantidad}
                    = ${(i.precio * i.cantidad).toFixed(2)} €
                </span>
                <button onclick="tpvRemoveProducto(${index})"
                        style="font-size:18px;padding:0 10px">
                    ❌
                </button>
            </div>
        `;
    });

    jQuery("#tpv-ticket").html(html);
    jQuery("#tpv-total").text("Total: " + total.toFixed(2) + " €");
}

function tpvRemoveProducto(index){
    if(!tpvTicket[index]) return;

    tpvTicket[index].cantidad--;

    if(tpvTicket[index].cantidad <= 0){
        tpvTicket.splice(index, 1);
    }

    tpvRenderTicket();
}


    ');
});



/* ===============================
   CSS
   =============================== */
add_action('wp_enqueue_scripts', function () {
    wp_add_inline_style('wp-block-library', '
        .tpv-btn {
            font-size: 22px;
            padding: 20px;
            margin: 10px;
            width: 220px;
        }
        .tpv-pago {
            font-size: 28px;
            padding: 30px;
            margin: 20px;
            width: 260px;
        }
        #tpv-productos {
            display: flex;
            flex-wrap: wrap;
            max-height: 65vh;
            overflow-y: auto;
        }
    ');
add_action('wp_enqueue_scripts', function () {
    if (is_page('panel-tpv')) {
        wp_add_inline_style('wp-block-library', '
            header, footer, nav {
                display: none !important;
            }
            body {
                margin: 0;
            }
        ');
    }
});

});

