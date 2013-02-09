#ifndef __O_BASEMENT_H__ 
#define __O_BASEMENT_H__ (1)

#include <tr1/memory>
#include <vector>
#include <string>
#include <sstream>


// BUGBUG : TODO : Implement
class TxError {
public :    
    std::string toString() const {
        std::string s = "TxError";
        // TODO : Implement
        return s;
    }
};

typedef std::string TxString;
typedef std::tr1::shared_ptr<TxString> TxStringPtr;

class TxStringArray : public std::vector<TxStringPtr> {
public :
    std::string toString() const {
        std::string s = "TxStringArray";
        // TODO : Implement
        return s;
    }
};
class TxImage {
};

class TxData {
private:
    void * data_; 
    unsigned int length_;
public :    
    TxData(void * data, unsigned int length)
    {
        data_ = data;
        length_ = length; 
    };
    void * bytes() const { return data_; };
    std::string toString() const {
        std::ostringstream ostream;
        ostream << "TxData(data=" << data_ << ",length=" << length_;
        return ostream.str(); 
    };
};

class TxTimeInterval {
};
#endif
