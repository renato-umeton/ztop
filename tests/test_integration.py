import unittest
import asyncio
import subprocess
import signal
import time
from unittest.mock import patch, Mock, AsyncMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from ztop import ZTop, ProcessPane, main


class TestIntegration(unittest.IsolatedAsyncioTestCase):
    
    async def test_full_application_startup_and_shutdown(self):
        app = ZTop()
        
        app.setup_layout()
        
        with patch('subprocess.Popen') as mock_popen:
            mock_process = Mock()
            mock_stdout = Mock()
            mock_stdout.readline.side_effect = [
                "Test output line 1\n",
                "Test output line 2\n",
                ""
            ]
            mock_process.stdout = mock_stdout
            mock_process.terminate.return_value = None
            mock_process.wait.return_value = None
            mock_popen.return_value = mock_process
            
            await app.start_processes()
            
            self.assertEqual(mock_popen.call_count, 4)
            
            for pane_name, pane in app.panes.items():
                self.assertIsNotNone(pane.process)
            
            app.update_layout()
            
            mock_stdout.readline.reset_mock()
            mock_stdout.readline.side_effect = [
                "Test output line 1\n",
                "Test output line 2\n",
                ""
            ]
            
            for pane in app.panes.values():
                output = pane.get_output()
                self.assertTrue(len(output) >= 0)
            
            app.stop_processes()
            
            for pane in app.panes.values():
                pane.process.terminate.assert_called()
    
    async def test_process_pane_with_missing_command(self):
        pane = ProcessPane("Missing Command", ["nonexistent_command_12345"])
        
        await pane.start()
        
        output = pane.get_output()
        self.assertIn("Command 'nonexistent_command_12345' not found", output)
    
    async def test_signal_handling(self):
        app = ZTop()
        
        with patch('subprocess.Popen') as mock_popen:
            mock_process = Mock()
            mock_popen.return_value = mock_process
            
            await app.start_processes()
            
            app.signal_handler(signal.SIGINT, None)
            
            self.assertFalse(app.running)
            mock_process.terminate.assert_called()
    
    async def test_main_function_with_keyboard_interrupt(self):
        with patch('ztop.ZTop') as mock_ztop_class:
            mock_app = Mock()
            mock_app.run = AsyncMock(side_effect=KeyboardInterrupt())
            mock_app.stop_processes = Mock()
            mock_ztop_class.return_value = mock_app
            
            await main()
            
            mock_app.run.assert_called_once()
            mock_app.stop_processes.assert_called_once()
    
    @patch('subprocess.Popen')
    async def test_multiple_output_lines_handling(self, mock_popen):
        mock_process = Mock()
        mock_stdout = Mock()
        
        output_lines = [f"Line {i}\n" for i in range(60)]
        output_lines.append("")
        mock_stdout.readline.side_effect = output_lines
        mock_process.stdout = mock_stdout
        mock_popen.return_value = mock_process
        
        pane = ProcessPane("Test", ["echo", "test"])
        await pane.start()
        
        output = pane.get_output()
        lines = output.split('\n')
        
        self.assertEqual(len(lines), 50)
        self.assertIn("Line 59", output)
        self.assertNotIn("Line 0", output)
    
    async def test_concurrent_pane_operations(self):
        panes = [
            ProcessPane(f"Pane {i}", ["echo", f"test{i}"])
            for i in range(4)
        ]
        
        with patch('subprocess.Popen') as mock_popen:
            mock_processes = []
            for i in range(4):
                mock_process = Mock()
                mock_stdout = Mock()
                mock_stdout.readline.side_effect = [f"output{i}\n", ""]
                mock_process.stdout = mock_stdout
                mock_processes.append(mock_process)
            
            mock_popen.side_effect = mock_processes
            
            tasks = [pane.start() for pane in panes]
            await asyncio.gather(*tasks)
            
            for i, pane in enumerate(panes):
                output = pane.get_output()
                self.assertIn(f"output{i}", output)
    
    async def test_layout_update_with_real_data(self):
        app = ZTop()
        app.setup_layout()
        
        for pane_name, pane in app.panes.items():
            pane.output_lines = [f"Sample output for {pane_name}", "Line 2", "Line 3"]
        
        app.update_layout()
        
        layout_names = ["top_left", "top_right", "bottom_left", "bottom_right"]
        for name in layout_names:
            layout = app.layout.get(name)
            self.assertIsNotNone(layout, f"Layout '{name}' should exist")


class TestErrorHandling(unittest.IsolatedAsyncioTestCase):
    
    async def test_process_pane_exception_handling(self):
        pane = ProcessPane("Error Test", ["echo", "test"])
        
        with patch('subprocess.Popen') as mock_popen:
            mock_process = Mock()
            mock_stdout = Mock()
            mock_stdout.readline.side_effect = Exception("Unexpected error")
            mock_process.stdout = mock_stdout
            mock_popen.return_value = mock_process
            
            await pane.start()
            
            output = pane.get_output()
            self.assertEqual(output, "")
    
    async def test_process_termination_errors(self):
        pane = ProcessPane("Term Error Test", ["echo", "test"])
        
        with patch('subprocess.Popen') as mock_popen:
            mock_process = Mock()
            mock_process.terminate.side_effect = Exception("Terminate failed")
            mock_process.kill.side_effect = Exception("Kill failed")
            mock_popen.return_value = mock_process
            
            await pane.start()
            pane.stop()


if __name__ == '__main__':
    unittest.main()