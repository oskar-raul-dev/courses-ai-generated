import com.mongodb.MongoClient; import com.mongodb.MongoClientURI;
import org.bson.Document;
public class Probe {
  public static void main(String[] a) {
    String uri = System.getenv("MONGO_URI");
    try (MongoClient c = new MongoClient(new MongoClientURI(uri))) {
      Document b = c.getDatabase("admin").runCommand(new Document("buildInfo", 1));
      System.out.println("  OK  driver 3.8.2 -> servidor " + b.getString("version"));
    } catch (Throwable e) {
      System.out.println("  FALLA  " + e.getClass().getSimpleName() + ": "
        + String.valueOf(e.getMessage()).replaceAll("\\s+"," ").substring(0, Math.min(150, String.valueOf(e.getMessage()).length())));
    }
  }
}
