package pt.anunciosloc.server.publisher;

import com.sun.net.httpserver.HttpContext;
import com.sun.net.httpserver.HttpServer;

import jakarta.xml.ws.Endpoint;

import pt.anunciosloc.server.filter.CORSFilter;
import pt.anunciosloc.server.service.AnunciosLocServiceImpl;

import java.net.InetSocketAddress;


public class ServidorPublisher {


    public static void main(String[] args) throws Exception {


        int porta = 8082;


        // Criar servidor HTTP
        HttpServer server = HttpServer.create(
                new InetSocketAddress("0.0.0.0", porta),
                0
        );


        // Criar contexto SOAP
        HttpContext context = server.createContext(
                "/ws/anunciosloc"
        );


        // Ativar CORS
        context.getFilters()
                .add(new CORSFilter());


        // Criar serviço SOAP
        Endpoint endpoint =
                Endpoint.create(
                        new AnunciosLocServiceImpl()
                );


        // Publicar SOAP dentro do HttpServer
        endpoint.publish(context);



        // Iniciar servidor
        server.start();



        System.out.println("=================================");
        System.out.println(" SERVIDOR SOAP INICIADO");
        System.out.println(" Porta: " + porta);
        System.out.println(
            " WSDL: http://localhost:"
            + porta
            + "/ws/anunciosloc?wsdl"
        );
        System.out.println(" CORS ATIVO");
        System.out.println("=================================");


        System.out.println("Pressione ENTER para parar");


        System.in.read();



        // Encerrar
        endpoint.stop();

        server.stop(0);


        System.out.println("Servidor terminado");
    }
}