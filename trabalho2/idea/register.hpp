#ifndef _INCLUDE_REGISTER_HPP
#define _INCLUDE_REGISTER_HPP
#include <stdint.h> 

class IRegister {
    public:
        virtual uint32_t    readUnsigned() = 0;
        virtual int32_t     read() = 0;
        virtual void        write(const uint32_t&value) = 0;
};

class ConstantGenerator: public IRegister {
    public:

        uint32_t readUnsigned() {
            return 0;
        }

        int32_t read() {
            return 0;
        }

        void write(const uint32_t&value) {}
};

class Register : public IRegister {
    private:
        uint32_t value;
    public:

        int32_t read() {
            return (int32_t) value;
        }

        uint32_t readUnsigned() {
            return value;
        }

        void write(const uint32_t&value) {
            this->value = value;
        }

};

#endif