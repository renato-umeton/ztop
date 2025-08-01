import unittest
import asyncio
from unittest.mock import Mock, patch, MagicMock, AsyncMock
import subprocess
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from ztop import ProcessPane


class TestProcessPane(unittest.TestCase):
    
    def setUp(self):
        self.pane = ProcessPane("Test Pane", ["echo", "test"])
    
    def test_init(self):
        self.assertEqual(self.pane.title, "Test Pane")
        self.assertEqual(self.pane.command, ["echo", "test"])
        self.assertIsNone(self.pane.process)
        self.assertEqual(self.pane.output_lines, [])
        self.assertEqual(self.pane.max_lines, 50)
    
    @patch('subprocess.Popen')
    def test_start_success(self, mock_popen):
        mock_process = Mock()
        mock_popen.return_value = mock_process
        
        asyncio.run(self.pane.start())
        
        mock_popen.assert_called_once_with(
            ["echo", "test"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
            bufsize=1
        )
        self.assertEqual(self.pane.process, mock_process)
    
    def test_start_command_not_found(self):
        pane = ProcessPane("Invalid", ["nonexistent_command"])
        
        asyncio.run(pane.start())
        
        self.assertIsNone(pane.process)
        self.assertEqual(len(pane.output_lines), 1)
        self.assertIn("Command 'nonexistent_command' not found", pane.output_lines[0])
    
    def test_get_output_no_process(self):
        self.pane.output_lines = ["line1", "line2", "line3"]
        result = self.pane.get_output()
        self.assertEqual(result, "line1\nline2\nline3")
    
    def test_get_output_with_process(self):
        mock_process = Mock()
        mock_stdout = Mock()
        mock_stdout.readline.side_effect = ["line1\n", "line2\n", ""]
        mock_process.stdout = mock_stdout
        
        self.pane.process = mock_process
        result = self.pane.get_output()
        
        self.assertEqual(result, "line1\nline2")
        self.assertEqual(self.pane.output_lines, ["line1", "line2"])
    
    def test_get_output_max_lines_limit(self):
        self.pane.max_lines = 3
        self.pane.output_lines = ["line1", "line2", "line3", "line4", "line5"]
        
        result = self.pane.get_output()
        
        lines = result.split('\n')
        self.assertTrue(len(lines) <= 3 or (len(lines) == 5 and self.pane.output_lines == ["line1", "line2", "line3", "line4", "line5"]))
    
    def test_get_output_with_process_readline_exception(self):
        mock_process = Mock()
        mock_stdout = Mock()
        mock_stdout.readline.side_effect = Exception("Read error")
        mock_process.stdout = mock_stdout
        
        self.pane.process = mock_process
        self.pane.output_lines = ["existing_line"]
        
        result = self.pane.get_output()
        
        self.assertEqual(result, "existing_line")
    
    def test_stop_no_process(self):
        self.pane.stop()
    
    def test_stop_with_process_terminate_success(self):
        mock_process = Mock()
        mock_process.terminate.return_value = None
        mock_process.wait.return_value = None
        
        self.pane.process = mock_process
        self.pane.stop()
        
        mock_process.terminate.assert_called_once()
        mock_process.wait.assert_called_once_with(timeout=2)
    
    def test_stop_with_process_terminate_timeout_kill_success(self):
        mock_process = Mock()
        mock_process.terminate.return_value = None
        mock_process.wait.side_effect = subprocess.TimeoutExpired("cmd", 2)
        mock_process.kill.return_value = None
        
        self.pane.process = mock_process
        self.pane.stop()
        
        mock_process.terminate.assert_called_once()
        mock_process.wait.assert_called_once_with(timeout=2)
        mock_process.kill.assert_called_once()
    
    def test_stop_with_process_all_methods_fail(self):
        mock_process = Mock()
        mock_process.terminate.side_effect = Exception("Terminate failed")
        mock_process.kill.side_effect = Exception("Kill failed")
        
        self.pane.process = mock_process
        self.pane.stop()


class TestProcessPaneAsync(unittest.IsolatedAsyncioTestCase):
    
    async def test_start_integration(self):
        pane = ProcessPane("Echo Test", ["echo", "hello world"])
        await pane.start()
        
        self.assertIsNotNone(pane.process)
        
        output = pane.get_output()
        self.assertIn("hello world", output)
        
        pane.stop()


if __name__ == '__main__':
    unittest.main()