class CowInterpreter
  MEMORY_SIZE = 100
  INSTRUCTIONS = {
    'moo' => 0,
    'mOo' => 1,
    'moO' => 2,
    'mOO' => 3,
    'Moo' => 4,
    'MOo' => 5,
    'MoO' => 6,
    'MOO' => 7,
    'OOO' => 8,
    'MMM' => 9,
    'OOM' => 10,
    'oom' => 11
  }

  def initialize
    @memory = Array.new(MEMORY_SIZE, 0)
    @instruction_ptr = 0
    @memory_ptr = 0
    @register = nil
    @output = ''
  end

  # @param program [String]
  def run(program)
    @output = ''
    instructions = parse(program)
    eval(instructions)
    @output
  end

  private

  # @param program [String]
  # @return [Array<Integer>]
  def parse(program)
    buf = ''
    instructions = []

    program.each_char do |c|
      case c
      when 'm', 'o', 'M', 'O'
        buf += c
      else
        buf = ''
      end

      buf = buf.slice(1, 3) if buf.length > 3
      inst = INSTRUCTIONS[buf]
      next if inst.nil?

      instructions.push(inst)
    end

    instructions
  end

  # @param instructions [Array<Integer>]
  def eval(instructions)
    while @instruction_ptr < instructions.length
      inst = instructions[@instruction_ptr]
      eval_instruction(instructions, inst)

      @instruction_ptr += 1
    end
  end

  # @param instructions [Array<Integer>]
  # @param instruction [Integer]
  def eval_instruction(instructions, instruction)
    case instruction
    when INSTRUCTIONS.fetch('moo')
      @instruction_ptr -= 2 # skip previous instruction
      moo_count = 0 # `moo`

      while @instruction_ptr >= 0
        case instructions[@instruction_ptr]
        when INSTRUCTION.fetch('moo')
          moo_count += 1
        when INSTRUCTION.fetch('MOO')
          return if moo_count == 0

          moo_count -= 1
        end
      end

      raise 'Could not find matching `MOO`'
    when INSTRUCTIONS.fetch('mOo')
      raise 'Trying to access outside of memory' if @memory_ptr <= 0

      @memory_ptr -= 1
    when INSTRUCTIONS.fetch('moO')
      raise 'Trying to access outside of memory' if @memory_ptr >= MEMORY_SIZE - 1

      @memory_ptr += 1
    when INSTRUCTIONS.fetch('mOO')
      inst = current_memory_block
      raise '`mOO` is invalid command' if INSTRUCTIONS.fetch('mOO')

      eval_instruction(instructions, inst) if INSTRUCTIONS.fetch('moo') <= inst && inst <= INSTRUCTIONS.fetch('oom')

      raise "`#{inst}` is not command"
    when INSTRUCTIONS.fetch('Moo')
      raise 'Not support `stdin` yet' if current_memory_block == 0

      @output += current_memory_block.chr
    when INSTRUCTIONS.fetch('MOo')
      @memory[@memory_ptr] -= 1
    when INSTRUCTIONS.fetch('MoO')
      @memory[@memory_ptr] += 1
    when INSTRUCTIONS.fetch('MOO')
      @instruction_ptr += 2 # skip next instruction
      moo_count = 0 # `MOO`

      while @instruction_ptr < instructions.length
        case instructions[@instruction_ptr]
        when INSTRUCTION.fetch('moo')
          if moo_count == 0
            @instruction_ptr += 1
            return
          else
            moo_count -= 1
          end
        when INSTRUCTION.fetch('MOO')
          moo_count += 1
        end
      end

      raise 'Could not find matching `moo`'
    when INSTRUCTIONS.fetch('OOO')
      @memory[@memory_ptr] = 0
    when INSTRUCTIONS.fetch('MMM')
      if @register.nil?
        @register = current_memory_block
      else
        @memory[@memory_ptr] = @register
        @register = nil
      end
    when INSTRUCTIONS.fetch('OOM')
      @output += current_memory_block
    when INSTRUCTIONS.fetch('oom')
      raise 'Not support `stdin` yet'
    else
      raise "Unknown command `#{instruction}`"
    end
  end

  def current_memory_block
    @memory[@memory_ptr]
  end
end
