=begin
 * UNIVERSIDADE DE BRASÍLIA
 * INSTITUTO DE CIÊNCIAS EXATAS 
 * DEPARTAMENTO DE CIÊNCIA DA COMPUTAÇÃO
 * 116394 ORGANIZAÇÃO E ARQUITETURA DE COMPUTADORES 
 * TURMA C - 2021/1
 *
 * Trabalho II: Simulador RISCV (32 bits)
 * Autor: SAMUEL JAMES DE LIMA BARROSO
=end

text = File.read("instruction_set")

instructions = []

text.each_line do |line|
    match = /^([a-z]*)\s*([A-Z])\s*(0b[0-1]*)\s*(0b[0-1]*)\s*(0b[0-1]*)\s*"(.*)(?<!\\)"/
    
    if line =~ match then
        instructions << [$1,$2,$3,$4,$5,$6.gsub(";", ";\n\t").gsub("{", "{\n\t").gsub("\t}", "}\n")]
    end
end

template =  File.read("instructions.cpp.template")

code = ""
template.each_line do |line|
    match = /(.*)\[(.*)\](.*)/
    if line =~ match then
        pref = $1
        midd = $2
        suff = $3
        instructions.each do |instruction|
            code += pref
            code += midd.gsub('$name', instruction[0]).gsub('$type', instruction[1]).gsub('$opcode', instruction[2]).gsub('$funct3', instruction[3]).gsub('$funct7', instruction[4]).gsub('$code', instruction[5])
            code += suff
            code += "\n"
        end
    else
        code += line
    end
end

File.open("../src/Instructions.cpp", 'w') do 
    |file| file.write(code) 
end

