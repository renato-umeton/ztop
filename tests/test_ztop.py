import unittest
import asyncio
import signal
from unittest.mock import Mock, patch, MagicMock, AsyncMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from ztop import ZTop, ProcessPane


class TestZTop(unittest.TestCase):
    
    def setUp(self):
        self.ztop = ZTop()
    
    def test_init(self):
        self.assertIsNotNone(self.ztop.console)
        self.assertIsNotNone(self.ztop.layout)
        self.assertEqual(len(self.ztop.panes), 4)
        self.assertTrue(self.ztop.running)
        
        expected_panes = ["htop_cpu", "htop_mem", "mactop", "ctop"]
        for pane_name in expected_panes:
            self.assertIn(pane_name, self.ztop.panes)
            self.assertIsInstance(self.ztop.panes[pane_name], ProcessPane)
    
    def test_pane_configurations(self):
        self.assertEqual(self.ztop.panes["htop_cpu"].title, "htop (CPU)")
        self.assertEqual(self.ztop.panes["htop_cpu"].command, ["htop", "--sort-key", "PERCENT_CPU"])
        
        self.assertEqual(self.ztop.panes["htop_mem"].title, "htop (Memory)")
        self.assertEqual(self.ztop.panes["htop_mem"].command, ["htop", "--sort-key", "PERCENT_MEM"])
        
        self.assertEqual(self.ztop.panes["mactop"].title, "mactop")
        self.assertEqual(self.ztop.panes["mactop"].command, ["mactop"])
        
        self.assertEqual(self.ztop.panes["ctop"].title, "ctop")
        self.assertEqual(self.ztop.panes["ctop"].command, ["ctop"])
    
    def test_setup_layout(self):
        self.ztop.setup_layout()
        
        layout_names = ["top", "bottom", "top_left", "top_right", "bottom_left", "bottom_right"]
        for name in layout_names:
            layout = self.ztop.layout.get(name)
            self.assertIsNotNone(layout, f"Layout '{name}' should exist")
    
    @patch('ztop.Panel')
    @patch('ztop.Text')
    def test_update_layout(self, mock_text, mock_panel):
        mock_text.return_value = "mock_text"
        mock_panel.return_value = "mock_panel"
        
        for pane in self.ztop.panes.values():
            pane.get_output = Mock(return_value="test output")
        
        self.ztop.setup_layout()
        self.ztop.update_layout()
        
        self.assertEqual(mock_text.call_count, 4)
        self.assertEqual(mock_panel.call_count, 4)
        
        mock_text.assert_any_call("test output", style="green")
        mock_text.assert_any_call("test output", style="yellow")
        mock_text.assert_any_call("test output", style="cyan")
        mock_text.assert_any_call("test output", style="magenta")
    
    def test_stop_processes(self):
        for pane in self.ztop.panes.values():
            pane.stop = Mock()
        
        self.ztop.stop_processes()
        
        for pane in self.ztop.panes.values():
            pane.stop.assert_called_once()
    
    def test_signal_handler(self):
        for pane in self.ztop.panes.values():
            pane.stop = Mock()
        
        self.ztop.signal_handler(signal.SIGINT, None)
        
        self.assertFalse(self.ztop.running)
        for pane in self.ztop.panes.values():
            pane.stop.assert_called_once()


class TestZTopAsync(unittest.IsolatedAsyncioTestCase):
    
    def setUp(self):
        self.ztop = ZTop()
    
    async def test_start_processes(self):
        for pane in self.ztop.panes.values():
            pane.start = AsyncMock()
        
        await self.ztop.start_processes()
        
        for pane in self.ztop.panes.values():
            pane.start.assert_called_once()
    
    @patch('ztop.Live')
    @patch('signal.signal')
    async def test_run_basic_flow(self, mock_signal, mock_live):
        mock_live_instance = Mock()
        mock_live.return_value.__enter__.return_value = mock_live_instance
        mock_live.return_value.__exit__.return_value = None
        
        for pane in self.ztop.panes.values():
            pane.start = AsyncMock()
            pane.stop = Mock()
            pane.get_output = Mock(return_value="test output")
        
        self.ztop.running = False
        
        await self.ztop.run()
        
        mock_signal.assert_any_call(signal.SIGINT, self.ztop.signal_handler)
        mock_signal.assert_any_call(signal.SIGTERM, self.ztop.signal_handler)
        
        for pane in self.ztop.panes.values():
            pane.start.assert_called_once()
            pane.stop.assert_called_once()
    
    @patch('ztop.Live')
    @patch('signal.signal')
    @patch('asyncio.sleep')
    async def test_run_with_keyboard_interrupt(self, mock_sleep, mock_signal, mock_live):
        mock_live_instance = Mock()
        mock_live.return_value.__enter__.return_value = mock_live_instance
        mock_live.return_value.__exit__.return_value = None
        
        for pane in self.ztop.panes.values():
            pane.start = AsyncMock()
            pane.stop = Mock()
            pane.get_output = Mock(return_value="test output")
        
        mock_sleep.side_effect = KeyboardInterrupt()
        
        await self.ztop.run()
        
        for pane in self.ztop.panes.values():
            pane.stop.assert_called_once()


class TestZTopIntegration(unittest.IsolatedAsyncioTestCase):
    
    @patch('subprocess.Popen')
    async def test_integration_with_mock_processes(self, mock_popen):
        mock_process = Mock()
        mock_stdout = Mock()
        mock_stdout.readline.side_effect = ["test output\n", ""]
        mock_process.stdout = mock_stdout
        mock_popen.return_value = mock_process
        
        ztop = ZTop()
        ztop.setup_layout()
        await ztop.start_processes()
        
        ztop.update_layout()
        
        self.assertEqual(mock_popen.call_count, 4)
        
        ztop.stop_processes()


if __name__ == '__main__':
    unittest.main()