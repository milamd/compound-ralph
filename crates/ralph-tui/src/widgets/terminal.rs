use tui_term::vt100::Parser;

pub struct TerminalWidget {
    parser: Parser,
}

impl Default for TerminalWidget {
    fn default() -> Self {
        Self::new()
    }
}

impl TerminalWidget {
    pub fn new() -> Self {
        Self {
            parser: Parser::new(24, 80, 0),
        }
    }

    pub fn process(&mut self, bytes: &[u8]) {
        self.parser.process(bytes);
    }

    pub fn clear(&mut self) {
        let (rows, cols) = (self.parser.screen().size().0, self.parser.screen().size().1);
        self.parser = Parser::new(rows, cols, 0);
    }

    pub fn size(&self) -> (u16, u16) {
        self.parser.screen().size()
    }

    pub fn parser(&self) -> &Parser {
        &self.parser
    }
}
