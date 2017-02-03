
import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UITextFieldDelegate, MCAdvertiserAssistantDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var textFieldMensagens: UITextField!
    @IBOutlet weak var textViewConversas: UITextView!
    
    //MARK: Propriedades
    var meuBuscador : MCBrowserViewController!
    var meuAdvertiser : MCAdvertiserAssistant!
    var minhaSecao : MCSession!
    var meuPeerId : MCPeerID!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Propriedades de TextField
        textFieldMensagens.delegate = self
        
        //Iniciando o Peer ID
        meuPeerId = MCPeerID(displayName: UIDevice.current.name)
        
        //Iniciando uma Seção
        minhaSecao = MCSession(peer: meuPeerId)
        minhaSecao.delegate = self
        
        //Inciando o Buscador
        meuBuscador = MCBrowserViewController(serviceType: "Chat", session: minhaSecao)
        meuBuscador.delegate = self
        
        //Inciando o Advertiser
        meuAdvertiser = MCAdvertiserAssistant(serviceType: "Chat", discoveryInfo: nil, session: minhaSecao)
        meuAdvertiser.delegate = self

    }
    
    //MARK: Actions
    @IBAction func buscar(_ sender: UIButton) {
        present(meuBuscador,animated: true)
        meuAdvertiser.start()
    }
    
    //MARK: Métodos de MCBrowserViewControllerDelegate
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        print("Pressionou Done")
        meuBuscador.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        print("Cancelou a busca")
        meuBuscador.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Métodos Próprios
    func tratarMensagem(mensagem umaMensagem : String, peer umPeer : MCPeerID) {
        var textoFinal = ""
        if umPeer == meuPeerId {
            textoFinal = "\nEu: \(umaMensagem)"
        } else {
            textoFinal = "\n\(umPeer.displayName): \(umaMensagem)"
        }
        textViewConversas.text! += textoFinal
    }
    
    func enviarMensagem() {
        let mensagem = textFieldMensagens.text!
        textFieldMensagens.text = ""
        
        let dado = mensagem.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        
        do{
            try minhaSecao.send(dado, toPeers: minhaSecao.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {}
        
        tratarMensagem(mensagem: mensagem, peer: meuPeerId)
        
        
    }
    
    //MARK: Métodos de MCSessionDelegate
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let mensagem = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
        DispatchQueue.main.async {
            self.tratarMensagem(mensagem: mensagem!, peer: peerID)
        }
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    
    
    //MARK: Métodos de UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textFieldMensagens.text!.isEmpty) {
            enviarMensagem()
        }
        textFieldMensagens.resignFirstResponder()
        return true
    }




}

