package pt.anunciosloc.server.filter;

import com.sun.net.httpserver.Filter;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;

public class CORSFilter extends Filter {

    @Override
    public void doFilter(HttpExchange exchange, Chain chain) throws IOException {

        // Permitir React, Flutter Web, etc.
        exchange.getResponseHeaders().add(
                "Access-Control-Allow-Origin",
                "*"
        );

        exchange.getResponseHeaders().add(
                "Access-Control-Allow-Methods",
                "GET, POST, PUT, DELETE, OPTIONS"
        );

        exchange.getResponseHeaders().add(
                "Access-Control-Allow-Headers",
                "Content-Type, Authorization, SOAPAction, X-Requested-With"
        );

        exchange.getResponseHeaders().add(
                "Access-Control-Max-Age",
                "3600"
        );


        // Responder ao preflight do navegador
        if ("OPTIONS".equalsIgnoreCase(exchange.getRequestMethod())) {

            exchange.sendResponseHeaders(200, -1);

            exchange.close();

            return;
        }


        // Continuar para o WebService SOAP
        chain.doFilter(exchange);
    }


    @Override
    public String description() {
        return "Filtro CORS para WebService SOAP";
    }
}